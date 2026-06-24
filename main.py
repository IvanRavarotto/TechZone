"""
=====================================================================================
Proyecto: TechZone - End-to-End Data Engineering Pipeline
Módulo: main.py (Orquestador Principal)
Autor: Iván Ravarotto
Descripción: Script central que orquesta el proceso ETL completo.
             Se encarga de cargar las variables de entorno, establecer la 
             conexión segura a MySQL y ejecutar secuencialmente la extracción, 
             transformación y carga (Upsert) de los datos.
=====================================================================================
"""

import os
import logging
from dotenv import load_dotenv
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# Importamos las funciones del módulo ETL
from etl_scripts.load_products import extract_data, transform_data, load_data

# =====================================================================================
# CONFIGURACIÓN PROFESIONAL DE LOGS
# Mantiene un registro en consola y en archivo de texto para auditoría
# =====================================================================================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("etl_process.log", encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("TechZone_Main")

def get_db_engine():
    """
    Carga las credenciales desde el archivo .env (aislamiento de secretos) 
    y construye el motor de conexión SQLAlchemy hacia MySQL.
    """
    load_dotenv()
    
    db_user = os.getenv("DB_USER")
    db_password_raw = os.getenv("DB_PASSWORD")
    db_host = os.getenv("DB_HOST")
    db_name = os.getenv("DB_NAME")
    
    if not all([db_user, db_password_raw, db_host, db_name]):
        logger.error("Faltan variables de entorno. Verifica tu archivo .env")
        raise ValueError("Credenciales de BD incompletas.")

    # Codificamos la contraseña para evitar errores con caracteres especiales (ej: @, -)
    db_password_encoded = quote_plus(db_password_raw)
    connection_string = f"mysql+mysqlconnector://{db_user}:{db_password_encoded}@{db_host}/{db_name}"
    
    return create_engine(connection_string)

def main():
    """Función principal que define el flujo del Pipeline de Datos."""
    logger.info("=== INICIANDO PIPELINE DE DATOS TECHZONE ===")
    try:
        # 1. Establecer Conexión
        engine = get_db_engine()
        with engine.connect() as conn:
            logger.info("🔌 Conexión a MySQL establecida de forma segura.")

        # 2. Definir ruta dinámica del archivo fuente (independiente del SO)
        file_path = os.path.join(os.getcwd(), "data_raw", "products.csv")

        # 3. Ejecutar el flujo ETL Modularizado
        df_raw = extract_data(file_path)         # Extracción
        df_clean = transform_data(df_raw)        # Transformación
        load_data(df_clean, engine)              # Carga (Upsert)

        logger.info("=== PIPELINE FINALIZADO CON ÉXITO ===")

    except Exception as e:
        logger.error(f"❌ El proceso fue interrumpido: {e}")

if __name__ == "__main__":
    main()