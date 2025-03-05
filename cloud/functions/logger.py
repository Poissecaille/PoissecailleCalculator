import logging
import logging.handlers
import os

LOG_DIR = "logs"
if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR)

LOG_FILE = os.path.join(os.getcwd(), LOG_DIR, "app.log")
LOG_FORMAT = "%(asctime)s - %(levelname)s - %(filename)s - %(funcName)s - %(message)s"
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"


logger = logging.getLogger("app_logger")
logger.setLevel(logging.DEBUG)  # Niveau minimum à capturer

# Gestionnaire de log pour la console
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)  # Affiche uniquement INFO et supérieur
console_handler.setFormatter(logging.Formatter(LOG_FORMAT, datefmt=DATE_FORMAT))

# Gestionnaire de log pour le fichier avec rotation (5 MB max, 5 fichiers)
file_handler = logging.handlers.RotatingFileHandler(
    LOG_FILE, maxBytes=5 * 1024 * 1024, backupCount=5, encoding="utf-8"
)
file_handler.setLevel(logging.DEBUG)  # Enregistre tous les logs
file_handler.setFormatter(logging.Formatter(LOG_FORMAT, datefmt=DATE_FORMAT))

# Ajout des gestionnaires au logger
logger.addHandler(console_handler)
logger.addHandler(file_handler)

# logger.debug("Ceci est un message de debug.")
# logger.info("Ceci est un message d'information.")
# logger.warning("Ceci est un message d'avertissement.")
# logger.error("Ceci est un message d'erreur.")
# logger.critical("Ceci est un message critique.")
