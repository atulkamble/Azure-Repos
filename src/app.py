#!/usr/bin/env python3
"""
Sample Python Application for Azure DevOps Demo
This application demonstrates a simple web service that can be used
for testing Azure DevOps pipelines and Git workflows.
"""

import json
import logging
from datetime import datetime
from typing import Dict, Any

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class AzureDevOpsApp:
    """
    Sample application class for demonstrating Azure DevOps integration
    """
    
    def __init__(self, config_path: str = "src/config.json"):
        """Initialize the application with configuration"""
        self.config = self._load_config(config_path)
        self.version = self.config.get("version", "1.0.0")
        logger.info(f"Application initialized with version {self.version}")
    
    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """Load configuration from JSON file"""
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            logger.info("Configuration loaded successfully")
            return config
        except FileNotFoundError:
            logger.warning(f"Config file {config_path} not found, using defaults")
            return {
                "version": "1.0.0",
                "environment": "development",
                "debug": True
            }
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in config file: {e}")
            return {}
    
    def get_status(self) -> Dict[str, Any]:
        """Get application status"""
        return {
            "status": "healthy",
            "version": self.version,
            "timestamp": datetime.now().isoformat(),
            "environment": self.config.get("environment", "unknown")
        }
    
    def process_data(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process incoming data (sample business logic)"""
        logger.info("Processing data...")
        
        # Sample processing logic
        processed_data = {
            "original_data": data,
            "processed_at": datetime.now().isoformat(),
            "status": "processed",
            "version": self.version
        }
        
        return processed_data
    
    def run(self):
        """Main application runner"""
        logger.info("Starting Azure DevOps Demo Application...")
        
        # Sample data processing
        sample_data = {
            "user_id": 12345,
            "action": "login",
            "timestamp": datetime.now().isoformat()
        }
        
        result = self.process_data(sample_data)
        print(json.dumps(result, indent=2))
        
        # Display status
        status = self.get_status()
        print(f"\nApplication Status: {json.dumps(status, indent=2)}")


def main():
    """Main entry point"""
    try:
        app = AzureDevOpsApp()
        app.run()
    except Exception as e:
        logger.error(f"Application error: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())