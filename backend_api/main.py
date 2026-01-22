from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from passlib.context import CryptContext
from typing import Optional
from datetime import date
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

# SCHEMAS

# recebendo do Flutter para criar conta
class PacienteCreate(BaseModel):
    nome: str
    email: str
    senha: str
    data_diagnostico: Optional[date] = None

# enviando para o Flutter como resposta
class PacienteResponse(BaseModel):
    id_usuario: int
    nome: str
    email: str
    sequencia_dias: int
    
    class Config:
        orm_mode = True

class MedicoCreate(BaseModel):
    nome: str
    email: str
    senha: str
    registro_profissional: str 

class LoginRequest(BaseModel):
    email: str
    senha: str
    
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
    novo_usuario = UsuarioDB(nome=paciente.nome, email=paciente.email, senha=hash_senha)
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

def login(dados: LoginRequest, db: Session = Depends(get_db)):
    print(f"Tentando logar: {dados.email} com senha: {dados.senha}") # DEBUG
    
    usuario = db.query(UsuarioDB).filter(UsuarioDB.email == dados.email).first()
    
    if not usuario:
        print("Usuário não encontrado no banco") # DEBUG
        raise HTTPException(status_code=401, detail="Email incorreto")
        
    print(f"Senha no banco: {usuario.senha}") # DEBUG
    
    senha_confere = pwd_context.verify(dados.senha, usuario.senha)
    print(f"A senha bate? {senha_confere}") # DEBUG

    if not senha_confere:
        raise HTTPException(status_code=401, detail="Senha incorreta")
    
    return {
        "mensagem": "Login deu bom",
        "id_usuario": usuario.id_usuario,
        "nome": usuario.nome
    }