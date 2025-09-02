from src.data_loader import AnimeDataLoader
from src.vector_store import VectorStoreBuilder
from config.parse_arguments import parse_args
from dotenv import load_dotenv
from utils.logger import get_logger
from utils.custom_exception import CustomException

load_dotenv()

logger = get_logger(__name__)

def main():
    try:
        # Parse command line arguments
        args = parse_args()
        
        logger.info("Starting to build pipeline...")
        logger.info(f"Using embedding model: {args.embed_model_name}")
        logger.info(f"Persist directory: {args.persist_dir}")

        loader = AnimeDataLoader("data/anime_with_synopsis.csv", "data/anime_updated.csv")
        processed_csv = loader.load_and_process()

        logger.info("Data loaded and processed...")

        vector_builder = VectorStoreBuilder(
            csv_path=processed_csv,
            persist_dir=args.persist_dir,
            embedding_model_name=args.embed_model_name
        )
        vector_builder.build_and_save_vectorstore()

        logger.info("Vector store built successfully....")

        logger.info("Pipeline built successfully....")
    except Exception as e:
            logger.error(f"Failed to execute pipeline {str(e)}")
            raise CustomException("Error during pipeline", e)
    
if __name__=="__main__":
     main()

