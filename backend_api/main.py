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
SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"

# criando o motor do banco
engine = create_engine(SQLALCHEMY_DATABASE_URL)
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
    id_paciente: int
    nome: str
    email: str
    sequencia_dias: int
    
    class Config:
        orm_mode = True


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

# Route 1: Criar Paciente
@app.post("/pacientes/", response_model=PacienteResponse)
def criar_paciente(paciente: PacienteCreate, db: Session = Depends(get_db)):
    # verificando se email já existe
    usuario_existente = db.query(UsuarioDB).filter(UsuarioDB.email == paciente.email).first()
    if usuario_existente:
        raise HTTPException(status_code=400, detail="Email já cadastrado")

    # Criando usuário
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
        id_paciente=novo_usuario.id_usuario,
        nome=novo_usuario.nome,
        email=novo_usuario.email,
        sequencia_dias=novo_paciente.sequencia_dias
    )

# Route 2: lendo dados do paciente
@app.get("/pacientes/{paciente_id}", response_model=PacienteResponse)
def ler_paciente(paciente_id: int, db: Session = Depends(get_db)):
    paciente = db.query(PacienteDB).join(UsuarioDB).filter(PacienteDB.id_paciente == paciente_id).first()
    
    if not paciente:
        raise HTTPException(status_code=404, detail="Paciente não encontrado")
        
    return PacienteResponse(
        id_paciente=paciente.id_paciente,
        nome=paciente.usuario.nome,
        email=paciente.usuario.email,
        sequencia_dias=paciente.sequencia_dias
    )

@app.post("/login")
def login(dados: LoginRequest, db: Session = Depends(get_db)):
    # buscando o usuário pelo email
    usuario = db.query(UsuarioDB).filter(UsuarioDB.email == dados.email).first()
    
    # se não achar o email OU se a senha não bater com o hash
    if not usuario or not pwd_context.verify(dados.senha, usuario.senha):
        raise HTTPException(status_code=401, detail="Email ou senha incorretos")
    
    # se deu tudo certo, retorna os dados básicos (pro app saber quem logou)
    # o ideal aqui seria gerar um token, ver posteriormente
    return {
        "mensagem": "Login realizado com sucesso",
        "id_usuario": usuario.id_usuario,
        "nome": usuario.nome
    }

# teste
@app.get("/")
def health_check():
    return {"status": "API online", "mensagem": "FUNCIONOU KCT!"}

@app.post("/login")
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