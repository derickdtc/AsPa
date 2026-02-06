from fastapi import FastAPI, HTTPException, Depends, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey, DateTime, DOUBLE_PRECISION, or_, Time, and_
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from passlib.context import CryptContext
from typing import Optional, List, Dict
from datetime import date, datetime, time
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
    prescricoes = relationship("PrescricaoDB", back_populates="paciente", cascade="all, delete-orphan")
    
class SessaoDB(Base):
    __tablename__ = "sessao"
    
    id_sessao = Column(Integer, primary_key=True, index=True)
    data_hora = Column(DateTime)
    duracao_realizada = Column(DOUBLE_PRECISION)
    dificuldade_info = Column(String(20))
    comentario_paciente = Column(String(150))
    
    id_paciente = Column("id_paciente_fk",Integer, ForeignKey("paciente.id_paciente"), nullable=False)
    
    paciente = relationship("PacienteDB", back_populates="sessoes")
    
class PrescricaoDB(Base):
    __tablename__ = "prescricao"
    
    id_prescricao = Column(Integer, primary_key=True, index=True)
    data_atualizacao = Column(DateTime)
    observacoes_gerais = Column(String(300))
    
    id_paciente = Column("id_paciente_fk",Integer, ForeignKey("paciente.id_paciente"), nullable=False)
    
    paciente = relationship("PacienteDB", back_populates="prescricoes")
    lembretes = relationship("LembreteDB", back_populates="prescricao", cascade="all, delete-orphan")
    
    prescricao_exercicio = relationship("PrescricaoExercicioDB", back_populates="prescricao")
    
class LembreteDB(Base):
    __tablename__ = "lembrete"
    
    id_lembrete = Column(Integer, primary_key=True, index=True)
    horario = Column(Time)
    nome_medicamento = Column(String(100))
    dose_diaria = Column(DOUBLE_PRECISION)
    tipo = Column(String(20))
    status = Column(String(10))
    
    id_prescricao = Column("id_prescricao_fk",Integer, ForeignKey("prescricao.id_prescricao"), nullable=False)
    
    prescricao = relationship("PrescricaoDB", back_populates="lembretes")

class ExercicioDB(Base):
    __tablename__ = "exercicio"
    
    id_exercicio = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100))
    descricao = Column(String(300))
    video_url = Column(String(255))
    tipo = Column(String(30))
    dificuldade_padrao = Column(String(10))
    
    prescricao_exercicio = relationship("PrescricaoExercicioDB", back_populates="exercicio")
    
class PrescricaoExercicioDB(Base):
    __tablename__ = "prescricao_exercicio"
    
    repeticoes = Column(Integer)
    duracao_minutos = Column(Integer)
    frequencia_semanal = Column(Integer)
    observacoes = Column(String(300))
    
    id_prescricao_fk = Column("id_prescricao_fk",Integer, ForeignKey("prescricao.id_prescricao"), primary_key=True)
    id_exercicio_fk = Column("id_exercicio_fk",Integer, ForeignKey("exercicio.id_exercicio"), primary_key=True)    
    
    prescricao = relationship("PrescricaoDB", back_populates="prescricao_exercicio")
    exercicio = relationship("ExercicioDB", back_populates="prescricao_exercicio")

class AmizadeDB(Base):
    __tablename__ = "amizade"
    
    id = Column(Integer, primary_key=True, index=True)
    solicitante_id = Column(Integer, ForeignKey("usuario.id_usuario")) 
    recebedor_id = Column(Integer, ForeignKey("usuario.id_usuario"))  
    status = Column(String, default="pendente") 
    data_criacao = Column(Date, default=date.today)

# histórico de mensagens
class MensagemDB(Base):
    __tablename__ = "mensagem"
    
    id = Column(Integer, primary_key=True, index=True)
    remetente_id = Column(Integer, ForeignKey("usuario.id_usuario"))
    destinatario_id = Column(Integer, ForeignKey("usuario.id_usuario"))
    conteudo = Column(String) 
    data_envio = Column(DateTime, default=datetime.now)
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
    
class PrescricaoCreate(BaseModel):
    id_paciente: int
    data_atualizacao: datetime
    observacoes_gerais: str
    
class LembreteCreate(BaseModel):
    id_prescricao: int
    horario: time
    nome_medicamento: str
    dose_diaria: float
    tipo: str
    status: str
    
class ExercicioCreate(BaseModel):
    nome: str
    descricao: str
    video_url: str
    tipo: str
    dificuldade_padrao: str
    
class PrescricaoExercicioCreate(BaseModel):
    id_prescricao: int
    id_exercicio: int
    repeticoes: int
    duracao_minutos: int
    frequencia_semanal: int
    observacoes: str

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
    
class UsuarioBusca(BaseModel):
    id: int
    nome: str
    email: str
    foto: Optional[str] = None
    
class PedidoAmizadeResponse(BaseModel):
    id: int
    solicitante: UsuarioBusca
    status: str

class PrescricaoUpdate(BaseModel):
    data_atualizacao: Optional[datetime] = None
    observacoes_gerais: Optional[str] = None
    
class LembreteUpdate(BaseModel):
    horario: Optional[time] = None
    nome_medicamento: Optional[str] = None
    dose_diaria: Optional[float] = None
    tipo: Optional[str] = None
    status: Optional[str] = None 
    
class ExercicioUpdate(BaseModel):
    nome: Optional[str] = None
    descricao: Optional[str] = None
    video_url: Optional[str] = None
    tipo: Optional[str] = None
    dificuldade_padrao: Optional[str] = None
    
class PrescricaoExercicioUpdate(BaseModel):
    repeticoes: Optional[int] = None
    duracao_minutos: Optional[int] = None
    frequencia_semanal: Optional[int] = None
    observacoes: Optional[str] = None
    
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

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, WebSocket] = {}

    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        self.active_connections[user_id] = websocket
        print(f"User {user_id} conectado.") # log para ver no terminal

    def disconnect(self, user_id: int):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
            print(f"User {user_id} desconectado.")

    async def send_personal_message(self, message: str, destinatario_id: int):
        if destinatario_id in self.active_connections:
            connection = self.active_connections[destinatario_id]
            try:
                await connection.send_text(message)
            except Exception as e:
                # se der erro ao enviar, remove ele da lista
                print(f"Erro ao enviar para {destinatario_id}: {e}")
                self.disconnect(destinatario_id)

manager = ConnectionManager()


import json

@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int, db: Session = Depends(get_db)):
    await manager.connect(websocket, user_id)
    try:
        while True:
            # espera a mensagem chegar
            data = await websocket.receive_text()
            
            try:
                data_json = json.loads(data)
                
                destinatario_id = int(data_json['destinatario_id'])
                conteudo_texto = data_json['mensagem']
                
                print(f"Recebido de {user_id} para {destinatario_id}: {conteudo_texto}") 

                nova_msg = MensagemDB(
                    remetente_id=user_id,
                    destinatario_id=destinatario_id,
                    conteudo=conteudo_texto,
                    data_envio=datetime.now()
                )
                db.add(nova_msg)
                db.commit() 
                
                msg_para_enviar = json.dumps({
                    "remetente_id": user_id,
                    "mensagem": conteudo_texto,
                    "data": str(datetime.now())
                })
                
                await manager.send_personal_message(msg_para_enviar, destinatario_id)
            
            except Exception as e:
                print(f"ERRO NO PROCESSAMENTO DA MENSAGEM: {e}")
                db.rollback()

    except WebSocketDisconnect:
        manager.disconnect(user_id)
    except Exception as e:
        print(f"Erro fatal no socket: {e}")
        manager.disconnect(user_id)
        
        
class MensagemResponse(BaseModel):
    id: int
    remetente_id: int
    conteudo: str
    data_envio: datetime
    class Config:
        from_attributes = True


@app.get("/chat/{amigo_id}")
def obter_historico(amigo_id: int, user_atual_id: int, db: Session = Depends(get_db)):
    # Pega mensagens onde (Eu mandei p/ Ele) OU (Ele mandou p/ Mim)
    historico = db.query(MensagemDB).filter(
        ((MensagemDB.remetente_id == user_atual_id) & (MensagemDB.destinatario_id == amigo_id)) |
        ((MensagemDB.remetente_id == amigo_id) & (MensagemDB.destinatario_id == user_atual_id))
    ).order_by(MensagemDB.data_envio.asc()).all()
    
    return [{
        "remetente_id": msg.remetente_id,
        "mensagem": msg.conteudo,
        "data": msg.data_envio
    } for msg in historico]

# busca pessoas (que não são é o atual usuario) para adicionar
@app.get("/usuarios/buscar/{termo}")
def buscar_usuarios(termo: str, user_id_logado: int, db: Session = Depends(get_db)):
    # busca por nome ou email
    usuarios = db.query(UsuarioDB).filter(
        (UsuarioDB.email.ilike(f"%{termo}%") | UsuarioDB.nome.ilike(f"%{termo}%")),
        UsuarioDB.id_usuario != user_id_logado
    ).all()
    
    resultado = []
    for u in usuarios:
        resultado.append({
            "id": u.id_usuario,
            "nome": u.nome,
            "email": u.email,
            "foto": u.foto
        })
    return resultado

@app.post("/amizade/solicitar")
def solicitar_amizade(solicitante_id: int, recebedor_id: int, db: Session = Depends(get_db)):
    # verifica se já existe pedido (aceito ou pendente)
    existente = db.query(AmizadeDB).filter(
        ((AmizadeDB.solicitante_id == solicitante_id) & (AmizadeDB.recebedor_id == recebedor_id)) |
        ((AmizadeDB.solicitante_id == recebedor_id) & (AmizadeDB.recebedor_id == solicitante_id))
    ).first()
    
    if existente:
        raise HTTPException(status_code=400, detail="Já existe uma relação entre vocês")
    
    nova_amizade = AmizadeDB(
        solicitante_id=solicitante_id,
        recebedor_id=recebedor_id,
        status="pendente"
    )
    db.add(nova_amizade)
    db.commit()
    return {"msg": "Solicitação enviada"}

@app.get("/amizade/pendentes/{meu_id}")
def listar_pendentes(meu_id: int, db: Session = Depends(get_db)):
    # busca onde "EU" sou o receptor e status é pendente
    pedidos = db.query(AmizadeDB).filter(
        AmizadeDB.recebedor_id == meu_id,
        AmizadeDB.status == "pendente"
    ).all()
    
    # dados de quem enviou
    resultado = []
    for p in pedidos:
        quem_pediu = db.query(UsuarioDB).filter(UsuarioDB.id_usuario == p.solicitante_id).first()
        resultado.append({
            "id_amizade": p.id,
            "nome": quem_pediu.nome,
            "email": quem_pediu.email,
            "id_usuario": quem_pediu.id_usuario # ID de quem pediu
        })
    return resultado

@app.put("/amizade/responder/{id_amizade}")
def responder_amizade(id_amizade: int, aceitar: bool, db: Session = Depends(get_db)):
    amizade = db.query(AmizadeDB).filter(AmizadeDB.id == id_amizade).first()
    
    if not amizade:
        raise HTTPException(status_code=404, detail="Pedido não encontrado")
    
    if aceitar:
        amizade.status = "aceito"
        db.commit()
        return {"msg": "Amizade aceita!"}
    else:
        db.delete(amizade) # se recusar, apaga o pedido
        db.commit()
        return {"msg": "Pedido recusado"}

@app.get("/amizade/meus_amigos/{meu_id}")
def listar_amigos(meu_id: int, db: Session = Depends(get_db)):
    amizades = db.query(AmizadeDB).filter(
        ((AmizadeDB.solicitante_id == meu_id) | (AmizadeDB.recebedor_id == meu_id)),
        AmizadeDB.status == "aceito"
    ).all()
    
    lista_amigos = []
    for a in amizades:
        id_amigo = a.recebedor_id if a.solicitante_id == meu_id else a.solicitante_id
        
        amigo = db.query(UsuarioDB).filter(UsuarioDB.id_usuario == id_amigo).first()
        lista_amigos.append({
            "id_usuario": amigo.id_usuario,
            "nome": amigo.nome,
            "email": amigo.email,
            "foto": amigo.foto
        })
        
    return lista_amigos


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

@app.post("/prescricoes/")
def criar_prescricao(prescricao: PrescricaoCreate, db: Session = Depends(get_db)):
    paciente = db.query(PacienteDB).filter(
        PacienteDB.id_paciente == prescricao.id_paciente
    ).first()

    if not paciente:
        raise HTTPException(status_code=404, detail="Paciente não encontrado")
    
    nova_prescricao = PrescricaoDB(data_atualizacao=prescricao.data_atualizacao, observacoes_gerais=prescricao.observacoes_gerais, paciente=paciente)
    # criando usuário
    db.add(nova_prescricao)
    db.commit()
    db.refresh(nova_prescricao) 
    
    return {"msg": "prescricao criada", "id_prescricao": nova_prescricao.id_prescricao, "id_paciente": paciente.id_paciente}

@app.get("/prescricoes/{prescricao_id}")
def ler_prescricao(prescricao_id: int, db: Session = Depends(get_db)):
    prescricao = db.query(PrescricaoDB).filter(PrescricaoDB.id_prescricao == prescricao_id).first()
    
    if not prescricao:
        raise HTTPException(status_code=404, detail="Prescricao não encontrada")
        
    return prescricao

@app.put("/prescricoes/{prescricao_id}")
def update_prescricao(prescricao_id: int, dados: PrescricaoUpdate, db: Session = Depends(get_db)):
    prescricao = db.query(PrescricaoDB).filter(PrescricaoDB.id_prescricao == prescricao_id).first()
    
    if not prescricao:
        raise HTTPException(status_code=404, detail="Prescricao não encontrada")
    
    if dados.data_atualizacao is not None:
        prescricao.data_atualizacao = dados.data_atualizacao
        
    if dados.observacoes_gerais is not None:
        prescricao.observacoes_gerais = dados.observacoes_gerais

    db.commit()
    db.refresh(prescricao)

    return {"msg": "prescricao alterada", "id_prescricao": prescricao.id_prescricao}

@app.delete("/prescricoes/{prescricao_id}")
def delete_prescricao(prescricao_id: int, db: Session = Depends(get_db)):
    prescricao = db.query(PrescricaoDB).filter(PrescricaoDB.id_prescricao == prescricao_id).first()
    
    if not prescricao:
        raise HTTPException(status_code=404, detail="Prescricao não encontrada")
    
    db.query(PrescricaoDB).filter(PrescricaoDB.id_prescricao == prescricao_id).delete()
    db.commit()
    
    return {"msg": "prescricao deletada", "id_prescricao": prescricao_id}

@app.post("/lembretes/")
def criar_lembrete(lembrete: LembreteCreate, db: Session = Depends(get_db)):
    prescricao = db.query(PrescricaoDB).filter(
        PrescricaoDB.id_prescricao == lembrete.id_prescricao
    ).first()

    if not prescricao:
        raise HTTPException(status_code=404, detail="Prescricao não encontrada")
    
    novo_lembrete = LembreteDB(horario = lembrete.horario, nome_medicamento = lembrete.nome_medicamento, dose_diaria = lembrete.dose_diaria, 
                                tipo = lembrete.tipo, status = lembrete.status, prescricao=prescricao)
    # criando usuário
    db.add(novo_lembrete)
    db.commit()
    db.refresh(novo_lembrete) 
    
    return {"msg": "lembrete criado", "id_lembrete": novo_lembrete.id_lembrete, "id_prescricao": prescricao.id_prescricao}

@app.get("/lembretes/{lembrete_id}")
def ler_lembrete(lembrete_id: int, db: Session = Depends(get_db)):
    lembrete = db.query(LembreteDB).filter(LembreteDB.id_lembrete == lembrete_id).first()
    
    if not lembrete:
        raise HTTPException(status_code=404, detail="Lembrete não encontrado")
        
    return lembrete

@app.put("/lembretes/{lembrete_id}")
def update_lembrete(lembrete_id: int, dados: LembreteUpdate, db: Session = Depends(get_db)):
    lembrete = db.query(LembreteDB).filter(LembreteDB.id_lembrete == lembrete_id).first()
    
    if not lembrete:
        raise HTTPException(status_code=404, detail="Lembrete não encontrado")
    
    if dados.horario is not None:
        lembrete.horario = dados.horario
        
    if dados.nome_medicamento is not None:
        lembrete.nome_medicamento = dados.nome_medicamento
        
    if dados.dose_diaria is not None:
        lembrete.dose_diaria = dados.dose_diaria
        
    if dados.tipo is not None:
        lembrete.tipo = dados.tipo
        
    if dados.status is not None:
        lembrete.status = dados.status

    db.commit()
    db.refresh(lembrete)

    return {"msg": "lembrete alterado", "id_lembrete": lembrete_id}

@app.delete("/lembretes/{lembrete_id}")
def delete_lembrete(lembrete_id: int, db: Session = Depends(get_db)):
    lembrete = db.query(LembreteDB).filter(LembreteDB.id_lembrete == lembrete_id).first()
    
    if not lembrete:
        raise HTTPException(status_code=404, detail="Lembrete não encontrado")
    
    db.query(LembreteDB).filter(LembreteDB.id_lembrete == lembrete_id).delete()
    db.commit()
    
    return {"msg": "lembrete deletado", "id_lembrete": lembrete_id}

@app.post("/exercicios/")
def criar_exercicio(exercicio: ExercicioCreate, db: Session = Depends(get_db)):
    
    novo_exercicio = ExercicioDB(nome = exercicio.nome, descricao = exercicio.descricao, video_url = exercicio.video_url,
                                 tipo = exercicio.tipo, dificuldade_padrao = exercicio.dificuldade_padrao)
    # criando usuário
    db.add(novo_exercicio)
    db.commit()
    db.refresh(novo_exercicio) 
    
    return {"msg": "exercício criado", "id_exercicio": novo_exercicio.id_exercicio}

@app.get("/exercicios/{exercicios_id}")
def ler_exercicio(exercicio_id: int, db: Session = Depends(get_db)):
    exercicio = db.query(ExercicioDB).filter(ExercicioDB.id_exercicio == exercicio_id).first()
    
    if not exercicio:
        raise HTTPException(status_code=404, detail="Exercício não encontrado")
        
    return exercicio

@app.put("/exercicios/{exercicio_id}")
def update_exercicio(exercicio_id: int, dados: ExercicioUpdate, db: Session = Depends(get_db)):
    exercicio = db.query(ExercicioDB).filter(ExercicioDB.id_exercicio == exercicio_id).first()
    
    if not exercicio:
        raise HTTPException(status_code=404, detail="Exercício não encontrado")
    
    if dados.nome is not None:
        exercicio.nome = dados.nome
        
    if dados.descricao is not None:
        exercicio.descricao = dados.descricao
        
    if dados.video_url is not None:
        exercicio.video_url = dados.video_url
        
    if dados.tipo is not None:
        exercicio.tipo = dados.tipo
        
    if dados.dificuldade_padrao is not None:
        exercicio.dificuldade_padrao = dados.dificuldade_padrao   
        
    db.commit()
    db.refresh(exercicio)

    return {"msg": "exercício alterado", "id_exercicio": exercicio_id}

@app.delete("/exercicios/{exercicio_id}")
def delete_exercicio(exercicio_id: int, db: Session = Depends(get_db)):
    exercicio = db.query(ExercicioDB).filter(ExercicioDB.id_exercicio == exercicio_id).first()
    
    if not exercicio:
        raise HTTPException(status_code=404, detail="Exercício não encontrado")
    
    db.query(ExercicioDB).filter(ExercicioDB.id_exercicio == exercicio_id).delete()
    db.commit()
    
    return {"msg": "exercício deletado", "id_exercicio": exercicio_id}

@app.post("/prescricoes/{prescricao_id}/exercicios")
def criar_prescricao_exercicio(prescricao_id: int ,prescricaoExercicio: PrescricaoExercicioCreate, db: Session = Depends(get_db)):
    
    nova_prescricao_exercicio = PrescricaoExercicioDB(id_prescricao_fk=prescricao_id, id_exercicio_fk=prescricaoExercicio.id_exercicio, repeticoes=prescricaoExercicio.repeticoes,
                                                      duracao_minutos=prescricaoExercicio.duracao_minutos, frequencia_semanal=prescricaoExercicio.frequencia_semanal,
                                                      observacoes=prescricaoExercicio.observacoes)
    # criando usuário
    db.add(nova_prescricao_exercicio)
    db.commit()
    db.refresh(nova_prescricao_exercicio) 
    
    return {"msg": "prescricao_exercicio criado", "id_exercicio": prescricaoExercicio.id_exercicio, "id_prescricao": prescricao_id}

@app.get("/prescricoes/{prescricao_id}/exercicios/{exercicio_id}")
def ler_prescricao_exercicio(exercicio_id: int, prescricao_id: int, db: Session = Depends(get_db)):
    prescricao_exercicio = db.query(PrescricaoExercicioDB).filter(and_(PrescricaoExercicioDB.id_exercicio_fk == exercicio_id,
                                                                       PrescricaoExercicioDB.id_prescricao_fk == prescricao_id)).first()
    
    if not prescricao_exercicio:
        raise HTTPException(status_code=404, detail="prescricao_exercicio não encontrado")
        
    return prescricao_exercicio

@app.put("/prescricoes/{prescricao_id}/exercicios/{exercicio_id}")
def update_prescricao_exercicio(exercicio_id: int, prescricao_id: int, dados: PrescricaoExercicioUpdate, db: Session = Depends(get_db)):
    prescricao_exercicio = db.query(PrescricaoExercicioDB).filter(and_(PrescricaoExercicioDB.id_exercicio_fk == exercicio_id,
                                                                       PrescricaoExercicioDB.id_prescricao_fk == prescricao_id)).first()
    
    if not prescricao_exercicio:
        raise HTTPException(status_code=404, detail="prescricao_exercicio não encontrado")
    
    if dados.repeticoes is not None:
        prescricao_exercicio.repeticoes = dados.repeticoes

    if dados.duracao_minutos is not None:
        prescricao_exercicio.duracao_minutos = dados.duracao_minutos
    
    if dados.frequencia_semanal is not None:
        prescricao_exercicio.frequencia_semanal = dados.frequencia_semanal
    
    if dados.observacoes is not None:
        prescricao_exercicio.observacoes = dados.observacoes
        
    db.commit()
    db.refresh(prescricao_exercicio)

    return {"msg": "prescricao_exercicio alterado", "id_prescricao": prescricao_id,"id_exercicio": exercicio_id}

@app.delete("/prescricoes/{prescricao_id}/exercicios/{exercicio_id}")
def delete_prescricao_exercicio(exercicio_id: int, prescricao_id: int, db: Session = Depends(get_db)):
    prescricao_exercicio = db.query(PrescricaoExercicioDB).filter(and_(PrescricaoExercicioDB.id_exercicio_fk == exercicio_id,
                                                                       PrescricaoExercicioDB.id_prescricao_fk == prescricao_id)).first()
    
    if not prescricao_exercicio:
        raise HTTPException(status_code=404, detail="prescricao_exercicio não encontrado")
    
    db.query(PrescricaoExercicioDB).filter(and_(PrescricaoExercicioDB.id_exercicio_fk == exercicio_id, PrescricaoExercicioDB.id_prescricao_fk == prescricao_id)).delete()
    db.commit()
    
    return {"msg": "prescricao_exercicio deletado", "id_prescricao": prescricao_id,"id_exercicio": exercicio_id}
    
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
