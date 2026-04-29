from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import auth, health, trips
from app.core.config import settings
from app.core.seed import seed_database


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize and seed database on startup
    seed_database()
    yield


app = FastAPI(
    title=settings.APP_NAME,
    description="EthioLiner Intercity Bus Booking & Transportation Platform API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API Routers
app.include_router(health.router, prefix=settings.API_V1_PREFIX)
app.include_router(auth.router, prefix=settings.API_V1_PREFIX)
app.include_router(trips.router, prefix=settings.API_V1_PREFIX)


@app.get("/")
def root():
    return {
        "message": "Welcome to EthioLiner API",
        "docs": "/docs",
        "health": f"{settings.API_V1_PREFIX}/health",
    }
