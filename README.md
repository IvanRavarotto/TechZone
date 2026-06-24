# 🧑‍💻 Proyecto TechZone: End-to-End Data Engineering Pipeline

## 🎯 Objetivo del Proyecto
**TechZone** es un proyecto integral de Ingeniería de Datos y Business Intelligence diseñado para una tienda ficticia de tecnología. El objetivo principal es construir una arquitectura robusta que permita la extracción, transformación y carga (ETL) de datos, la gestión de bases de datos relacionales, y la visualización final para la toma de decisiones.

En esta nueva versión (v2.0), la arquitectura ha sido refactorizada para incluir **Idempotencia (Upsert)**, **Orquestación centralizada** y **Seguridad de credenciales**.

## 🛠️ Stack Tecnológico Utilizado
* **Lenguaje Principal:** Python 3.x
* **Gestión de Datos (ETL):** Pandas, SQLAlchemy
* **Base de Datos:** MySQL (Despliegue local y en contenedores Docker)
* **Visualización:** Power BI
* **Orquestación y Seguridad:** `.env` (python-dotenv), Logging automatizado

---

## 🏗️ Arquitectura del Proyecto

El flujo de trabajo se divide en tres fases principales:

### Fase 1: Arquitectura de Base de Datos (SQL)
La base de datos MySQL está diseñada en **Tercera Forma Normal (3FN)** para garantizar la integridad referencial.
* **Modelado:** Tablas principales para Productos, Clientes y Ventas.
* **Seguridad y Auditoría:** Implementación de *Triggers* para registrar cambios históricos (ej. variaciones de precios).
* **Generación de Datos:** *Stored Procedures* que simulan transacciones y ventas aleatorias para poblar la base de datos de manera masiva.

### Fase 2: Pipeline ETL (Python)
Desarrollo de un flujo automatizado para la integración de datos provenientes de archivos CSV hacia la base de datos relacional.
* **Orquestación Centralizada:** Un script `main.py` actúa como controlador principal del proceso, generando logs detallados (`etl_process.log`) para facilitar la auditoría y el monitoreo.
* **Seguridad:** Las credenciales de conexión están aisladas mediante variables de entorno (`.env`), evitando la exposición de datos sensibles.
* **Lógica Upsert (Idempotencia):** El proceso ETL utiliza una técnica de "Staging Table" (Tabla temporal). En lugar de insertar datos a lo bruto, el pipeline compara los registros entrantes con la base de datos actual. Si el producto existe, actualiza el precio y stock (`UPDATE`); si es nuevo, lo inserta (`INSERT`). Esto garantiza que el script pueda ejecutarse múltiples veces sin generar duplicados.

### Fase 3: Business Intelligence (Power BI)
Conexión directa desde Power BI a la base de datos MySQL para transformar los datos crudos en información estratégica.
* Dashboard interactivo con KPIs de ventas, productos con bajo stock y rendimiento por categorías.

---

## 🚀 Cómo ejecutar el proyecto localmente

### 1. Clonar el repositorio
```bash
    git clone [https://github.com/IvanRavarotto/TechZone.git](https://github.com/IvanRavarotto/TechZone.git)
    cd TechZone
```

### 2. Configurar el Entorno Virtual
Es altamente recomendable utilizar un entorno virtual para aislar las dependencias:
```bash
    # Crear entorno
    python -m venv .venv

    # Activar entorno (Windows)
    .venv\Scripts\activate

    # Activar entorno (Linux/macOS)
    source .venv/bin/activate
```

### 3. Instalar dependencias
```bash
    pip install -r requirements.txt
```
(Nota: Si no tienes el archivo requirements.txt, puedes instalar las librerías con: pip install pandas sqlalchemy mysql-connector-python python-dotenv faker)

### 4. Configurar las Credenciales Seguras (.env)
Crea un archivo llamado .env en la raíz del proyecto y añade tus credenciales de MySQL:
```bash
    DB_USER=tu_usuario
    DB_PASSWORD=tu_contraseña
    DB_HOST=localhost
    DB_NAME=TechZone
```

### 5. Configurar la Base de Datos
Crea un archivo llamado .env en la raíz del proyecto y añade tus credenciales de MySQL:
1. Abre MySQL Workbench (o DBeaver) o tu terminal.
2. Ejecuta secuencialmente los scripts ubicados en la carpeta `sql_db/`:
    * `01_create_tables.sql`
    * `02_triggers.sql`
    * `03_stored_procedures.sql`


### 6. Ejecutar el ETL
Para iniciar la carga segura y sin duplicados de los productos desde el CSV a la base de datos, ejecuta:
```bash
    python main.py
```
(Puedes revisar la consola o el archivo `etl_process.log` para ver el estado de la operación paso a paso).


## 📈 Próximos Pasos (Roadmap)
* [x] Refactorización de Arquitectura (Staging & Upsert)

* [x] Centralización con Orquestador (main.py)

* [ ] Dockerización completa del pipeline (Docker Compose)

* [ ] Integración de herramientas como Apache Airflow o dbt


## 📬 Contacto
Iván Ravarotto | Data Engineer & Data Analyst
* Linkedin: https://www.linkedin.com/in/itravarotto/
* Github: https://github.com/IvanRavarotto
* Email: itravarotto@outlook.com

---

### 🗣️ Sobre los comentarios en tu código

Como ya reemplazaste el código espagueti por el código modular que armamos juntos en `load_products.py` y `main.py`, notarás que ya vienen con funciones de `logger.info()` y comentarios en español explicando cada paso (ej: *"Paso 2A: Actualizar los productos que YA EXISTEN"* o *"Paso 2B: Insertar SOLAMENTE los productos NUEVOS"*).

Para tus scripts de **SQL** en la carpeta `sql_db`, la mejor práctica no es llenar cada línea de texto, sino poner un bloque descriptivo al inicio del archivo.

**¿Quieres que te pase el bloque de comentarios en español para pegarlo al principio de tus 3 archivos SQL, o prefieres hacer el `git commit` de este nuevo README primero?**