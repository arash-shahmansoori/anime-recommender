import argparse


def parse_args():
    """Parse command line arguments for the application."""
    parser = argparse.ArgumentParser(
        description="Anime Recommender System with configurable embedding model"
    )
    
    parser.add_argument(
        "--embed-model-name",
        type=str,
        default="text-embedding-3-small",
        help="OpenAI embedding model name (default: text-embedding-3-small). Options: text-embedding-3-small, text-embedding-3-large, text-embedding-ada-002"
    )
    
    parser.add_argument(
        "--persist-dir",
        type=str,
        default="chroma_db",
        help="Directory to persist the vector store (default: chroma_db)"
    )
    
    parser.add_argument(
        "--csv-path",
        type=str,
        default="data/anime_with_synopsis.csv",
        help="Path to the CSV file with anime data (default: data/anime_with_synopsis.csv)"
    )
    
    return parser.parse_args()
