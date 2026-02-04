from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey, DateTime, DOUBLE_PRECISION
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from passlib.context import CryptContext
from typing import Optional
from datetime import date, datetime
import os
from dotenv import load_dotenv
from passlib.context import CryptContext
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware # <--- IMPORT NOVO

# carrega as variáveis do arquivo .env
load_dotenv()

print(f"User: {os.getenv('DB_USER')}")
print(f"Host: {os.getenv('DB_HOST')}")

# buscando os valores (ou retorna erro se não achar)
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

# str de conexão (NÃO MEXAM AQUI)
SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}?sslmode=require"

# criando o motor do banco
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"sslmode": "require"})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Fazendo hash da senha (encriptando)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# (Model) representação das tabelas do banco

class UsuarioDB(Base):
    __tablename__ = "usuario"
    
    id_usuario = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100))
    email = Column(String(150), unique=True, index=True)
    senha = Column(String(255))
    data_nascimento = Column(Date, nullable=True)
    foto = Column(String, nullable=True)
    # um usuário pode ter um perfil de paciente
    paciente = relationship("PacienteDB", back_populates="usuario", uselist=False)
    profissional_saude = relationship("ProfissionalSaudeDB", back_populates="usuario", uselist=False)

class ProfissionalSaudeDB(Base):
    __tablename__ = "profissional_saude"
    
    id_profissional_saude = Column(Integer, ForeignKey("usuario.id_usuario"), primary_key=True)
    registro_profissional = Column(String(20), unique=True, nullable=False) # CRM
    especialidade = Column(String(50))
    
    usuario = relationship("UsuarioDB", back_populates="profissional_saude")
    
class PacienteDB(Base):
    __tablename__ = "paciente"
    
    # o ID do paciente é o mesmo do usuário
    id_paciente = Column(Integer, ForeignKey("usuario.id_usuario"), primary_key=True)
    data_diagnostico = Column(Date)
    sequencia_dias = Column(Integer, default=0)
    
    usuario = relationship("UsuarioDB", back_populates="paciente")
    sessoes = relationship("SessaoDB", back_populates="paciente", cascade="all, delete-orphan")
    
class SessaoDB(Base):
    __tablename__ = "sessao"
    
    id_sessao = Column(Integer, primary_key=True, index=True)
    data_hora = Column(DateTime)
    duracao_realizada = Column(DOUBLE_PRECISION)
    dificuldade_info = Column(String(20))
    comentario_paciente = Column(String(150))
    
    id_paciente = Column("id_paciente_fk",Integer, ForeignKey("paciente.id_paciente"), nullable=False)
    
    paciente = relationship("PacienteDB", back_populates="sessoes")

# SCHEMAS

# recebendo do Flutter para criar conta
class PacienteCreate(BaseModel):
    nome: str
    email: str
    senha: str
    data_diagnostico: Optional[date] = None
    data_nascimento: Optional[date] = None
    foto: Optional[str] = None
    
class SessionCreate(BaseModel):
    id_paciente: int
    data_hora: datetime
    duracao_realizada: float
    dificuldade_info: str
    comentario_paciente: Optional[str] = None

# enviando para o Flutter como resposta
class PacienteResponse(BaseModel):
    id_usuario: int
    nome: str
    email: str
    sequencia_dias: int
    foto: Optional[str] = None
    class Config:
        from_attributes = True

class MedicoCreate(BaseModel):
    nome: str
    email: str
    senha: str
    registro_profissional: str 
    data_nascimento: Optional[date] = None
    foto: Optional[str] = None

class LoginRequest(BaseModel):
    email: str
    senha: str
    
class PacienteUpdate(BaseModel):
    nome: Optional[str] = None
    email: Optional[str] = None
    senha: Optional[str] = None
    data_diagnostico: Optional[date] = None
    sequencia_dias: Optional[int] = None
    
class MedicoUpdate(BaseModel):
    nome: Optional[str] = None
    email: Optional[str] = None
    senha: Optional[str] = None
    registro_profissional: Optional[str] = None
    
class SessaoUpdate(BaseModel):
    data_hora: Optional[datetime] = None
    duracao_realizada: Optional[float] = None
    dificuldade_info: Optional[str] = None
    comentario_paciente: Optional[str] = None
    
# as rotas que o Flutter vai chamar
app = FastAPI(title="API Parkinson App")
origins = ["*"] 

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# func aux para pegar a conexão com o banco
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# route pacientes
@app.post("/pacientes/", response_model=PacienteResponse)
def criar_paciente(paciente: PacienteCreate, db: Session = Depends(get_db)):
    # verificando se email já existe
    usuario_existente = db.query(UsuarioDB).filter(UsuarioDB.email == paciente.email).first()
    if usuario_existente:
        raise HTTPException(status_code=400, detail="Email já cadastrado")

    # criando usuário
    hash_senha = pwd_context.hash(paciente.senha) 
    novo_usuario = UsuarioDB(
        nome=paciente.nome, 
        email=paciente.email, 
        senha=hash_senha,
        data_nascimento=paciente.data_nascimento, 
        foto=paciente.foto                     
    )
    db.add(novo_usuario)
    db.commit()
    db.refresh(novo_usuario) 

    novo_paciente = PacienteDB(
        id_paciente=novo_usuario.id_usuario, 
        data_diagnostico=paciente.data_diagnostico
    )
    db.add(novo_paciente)
    db.commit()
    
    return PacienteResponse(
        id_usuario=novo_usuario.id_usuario,
        nome=novo_usuario.nome,
        email=novo_usuario.email,
        sequencia_dias=novo_paciente.sequencia_dias
    )
 
# route p/ ler dados do paciente
@app.get("/pacientes/{paciente_id}", response_model=PacienteResponse)
def ler_paciente(paciente_id: int, db: Session = Depends(get_db)):
    paciente = db.query(PacienteDB).join(UsuarioDB).filter(PacienteDB.id_paciente == paciente_id).first()
    
    if not paciente:
        raise HTTPException(status_code=404, detail="Paciente não encontrado")
        
    return PacienteResponse(
        id_usuario=paciente.id_paciente,
        nome=paciente.usuario.nome,
        email=paciente.usuario.email,
        sequencia_dias=paciente.sequencia_dias
    )
    
@app.put("/pacientes/{paciente_id}", response_model=PacienteResponse)
def update_paciente(paciente_id: int, dados: PacienteUpdate, db: Session = Depends(get_db)):
    paciente = db.query(PacienteDB).filter(PacienteDB.id_paciente == paciente_id).first()
    
    if not paciente:
        raise HTTPException(status_code=404, detail="Paciente não encontrado")
    
    usuario = paciente.usuario
    
    if dados.nome is not None:
        usuario.nome = dados.nome

    if dados.email is not None:
        email_existente = db.query(UsuarioDB).filter(
            UsuarioDB.email == dados.email,
            UsuarioDB.id_usuario != usuario.id_usuario
        ).first()

        if email_existente:
            raise HTTPException(status_code=400, detail="Email já cadastrado")

        usuario.email = dados.email

    if dados.senha is not None:
        usuario.senha = pwd_context.hash(dados.senha)

    if dados.data_diagnostico is not None:
        paciente.data_diagnostico = dados.data_diagnostico

    if dados.sequencia_dias is not None:
        paciente.sequencia_dias = dados.sequencia_dias

    db.commit()
    db.refresh(paciente)

    return PacienteResponse(
        id_usuario=usuario.id_usuario,
        nome=usuario.nome,
        email=usuario.email,
        sequencia_dias=paciente.sequencia_dias
    )
    
@app.delete("/pacientes/{paciente_id}", response_model=PacienteResponse)
def delete_paciente(paciente_id: int, db: Session = Depends(get_db)):
    paciente = db.query(PacienteDB).filter(PacienteDB.id_paciente == paciente_id).first()
    
    if not paciente:
        raise HTTPException(status_code=404, detail="Paciente não encontrado")
    
    response = PacienteResponse(
        id_usuario=paciente.id_paciente,
        nome=paciente.usuario.nome,
        email=paciente.usuario.email,
        sequencia_dias=paciente.sequencia_dias
    )
    
    db.query(PacienteDB).filter(PacienteDB.id_paciente == paciente_id).delete()
    db.commit()
    
    return response
    
# route medicos
@app.post("/medicos/")
def criar_medico(medico: MedicoCreate, db: Session = Depends(get_db)):
    # verificando se email é duplicado
    usuario_existente = db.query(UsuarioDB).filter(UsuarioDB.email == medico.email).first()
    if usuario_existente:
        raise HTTPException(status_code=400, detail="Email já cadastrado")

    # criando user base
    hash_senha = pwd_context.hash(medico.senha)
    novo_usuario = UsuarioDB(nome=medico.nome, email=medico.email, senha=hash_senha)
    db.add(novo_usuario)
    db.commit()
    db.refresh(novo_usuario)

    # criando perfil de proffisional
    novo_profissional = ProfissionalSaudeDB(
        id_profissional_saude=novo_usuario.id_usuario,
        registro_profissional=medico.registro_profissional
    )
    db.add(novo_profissional)
    db.commit()

    return {"msg": "Médico criado", "id_usuario": novo_usuario.id_usuario}

# route get medico
@app.get("/medicos/{medico_id}")
def ler_medico(medico_id: int, db: Session = Depends(get_db)):
    # busca na tabela profissional_saude e junta com usuario
    medico = db.query(ProfissionalSaudeDB).join(UsuarioDB).filter(ProfissionalSaudeDB.id_profissional_saude == medico_id).first()
    
    if not medico:
        raise HTTPException(status_code=404, detail="Médico não encontrado")
        
    return {
        "id_usuario": medico.id_profissional_saude,
        "nome": medico.usuario.nome,
        "email": medico.usuario.email,
        "crm": medico.registro_profissional
    }
    
@app.put("/medicos/{medico_id}")
def update_medico(medico_id: int, dados: MedicoUpdate, db: Session = Depends(get_db)):
    medico = db.query(ProfissionalSaudeDB).filter(ProfissionalSaudeDB.id_profissional_saude == medico_id).first()
    
    if not medico:
        raise HTTPException(status_code=404, detail="Paciente não encontrado")
    
    usuario = medico.usuario
    
    if dados.nome is not None:
        usuario.nome = dados.nome

    if dados.email is not None:
        email_existente = db.query(UsuarioDB).filter(
            UsuarioDB.email == dados.email,
            UsuarioDB.id_usuario != usuario.id_usuario
        ).first()

        if email_existente:
            raise HTTPException(status_code=400, detail="Email já cadastrado")

        usuario.email = dados.email

    if dados.senha is not None:
        usuario.senha = pwd_context.hash(dados.senha)

    if dados.registro_profissional is not None:
        medico.registro_profissional = dados.registro_profissional

    db.commit()
    db.refresh(medico)

    return medico

@app.delete("/medicos/{medico_id}")
def delete_medico(medico_id: int, db: Session = Depends(get_db)):
    medico = db.query(ProfissionalSaudeDB).filter(ProfissionalSaudeDB.id_profissional_saude == medico_id).first()
    
    if not medico:
        raise HTTPException(status_code=404, detail="Medico não encontrado")
    
    db.query(ProfissionalSaudeDB).filter(ProfissionalSaudeDB.id_profissional_saude == medico_id).delete()
    db.commit()
    
    return {"msg": "Médico deletado", "id_usuario": medico.id_profissional_saude}

@app.post("/sessoes/")
def criar_sessao(sessao: SessionCreate, db: Session = Depends(get_db)):
    paciente = db.query(PacienteDB).filter(
        PacienteDB.id_paciente == sessao.id_paciente
    ).first()

    if not paciente:
        raise HTTPException(status_code=404, detail="Paciente não encontrado")
    
    nova_sessao = SessaoDB(data_hora = sessao.data_hora, duracao_realizada = sessao.duracao_realizada, dificuldade_info = sessao.dificuldade_info
                            , comentario_paciente = sessao.comentario_paciente, paciente=paciente)
    # criando usuário
    db.add(nova_sessao)
    db.commit()
    db.refresh(nova_sessao) 
    
    return {"msg": "sessao criado", "id_sessao": nova_sessao.id_sessao, "id_paciente": paciente.id_paciente}

@app.get("/sessoes/{sessao_id}")
def ler_sessao(sessao_id: int, db: Session = Depends(get_db)):
    sessao = db.query(SessaoDB).filter(SessaoDB.id_sessao == sessao_id).first()
    
    if not sessao:
        raise HTTPException(status_code=404, detail="Sessao não encontrado")
        
    return sessao

@app.put("/sessoes/{sessao_id}")
def update_paciente(sessao_id: int, dados: SessaoUpdate, db: Session = Depends(get_db)):
    sessao = db.query(SessaoDB).filter(SessaoDB.id_sessao == sessao_id).first()
    
    if not sessao:
        raise HTTPException(status_code=404, detail="Sessao não encontrado")
    
    if dados.data_hora is not None:
        sessao.data_hora = dados.data_hora

    if dados.duracao_realizada is not None:
        sessao.duracao_realizada = dados.duracao_realizada

    if dados.dificuldade_info is not None:
        sessao.dificuldade_info = dados.dificuldade_info

    if dados.comentario_paciente is not None:
        sessao.comentario_paciente = dados.comentario_paciente

    db.commit()
    db.refresh(sessao)

    return {"msg": "sessao alterada", "id_sessao": sessao.id_sessao}

@app.delete("/sessoes/{sessao_id}")
def delete_sessao(sessao_id: int, db: Session = Depends(get_db)):
    sessao = db.query(SessaoDB).filter(SessaoDB.id_sessao == sessao_id).first()
    
    if not sessao:
        raise HTTPException(status_code=404, detail="Sessao não encontrado")
    
    db.query(SessaoDB).filter(SessaoDB.id_sessao == sessao_id).delete()
    db.commit()
    
    return {"msg": "sessao deletada", "id_sessao": sessao.id_sessao}
    
@app.post("/login")
def login(dados: LoginRequest, db: Session = Depends(get_db)):
    # busca qualquer usuário genérico (Nome/Email/Senha)
    usuario = db.query(UsuarioDB).filter(UsuarioDB.email == dados.email).first()
    
    if not usuario or not pwd_context.verify(dados.senha, usuario.senha):
        raise HTTPException(status_code=401, detail="Email ou senha incorretos")
    
    tipo_usuario = ""
    
    if usuario.paciente: 
        tipo_usuario = "paciente"
    elif usuario.profissional_saude:
        tipo_usuario = "medico"
    
    return {
        "mensagem": "Login realizado com sucesso",
        "id_usuario": usuario.id_usuario,
        "nome": usuario.nome,
        "tipo_usuario": tipo_usuario 
    }

# teste
@app.get("/")
def health_check():
    return {"status": "API online", "mensagem": "FUNCIONOU KCT!"}
