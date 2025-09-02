# Deployment Guide for Anime Recommender System

This guide covers deploying the anime recommender system using Docker and Kubernetes.

## Prerequisites

- Docker installed
- Kubernetes cluster (local or cloud)
- kubectl configured
- OpenAI and Groq API keys

## Docker Deployment

### 1. Build the Docker Image

```bash
# Build the image
docker build -t anime-recommender:latest .

# Verify the image
docker images | grep anime-recommender
```

### 2. Run with Docker

```bash
# Create a .env file with your API keys
cat > .env <<EOF
OPENAI_API_KEY=your-openai-api-key
GROQ_API_KEY=your-groq-api-key
EOF

# Run the container
docker run -d \
  --name anime-recommender \
  -p 8501:8501 \
  --env-file .env \
  -v $(pwd)/chroma_db:/app/chroma_db \
  -v $(pwd)/logs:/app/logs \
  anime-recommender:latest

# Check logs
docker logs -f anime-recommender
```

### 3. Build Vector Store in Container

If you haven't built the vector store yet:

```bash
# Execute build command inside container
docker exec -it anime-recommender \
  /app/.venv/bin/python pipeline/build_pipeline.py
```

### 4. Access the Application

Open your browser to `http://localhost:8501`

## Kubernetes Deployment

### ⚠️ IMPORTANT: Security First!

**NEVER commit real API keys to Git!** The `llmops-k8s.yaml` file does NOT contain a secrets section. You must create the secret separately using kubectl commands.

### 1. Prepare Secrets (Choose One Method)

#### Method A: Command Line (Recommended)
```bash
# Create secret with your actual API keys (not stored in any file)
kubectl create secret generic llmops-secrets \
  --from-literal=OPENAI_API_KEY='your-actual-openai-key' \
  --from-literal=GROQ_API_KEY='your-actual-groq-key'
```

#### Method B: Environment File
```bash
# Create .env file (NEVER commit this!)
cat > .env <<EOF
OPENAI_API_KEY=your-actual-openai-key
GROQ_API_KEY=your-actual-groq-key
EOF

# Add to .gitignore
echo ".env" >> .gitignore

# Create secret from env file
kubectl create secret generic llmops-secrets --from-env-file=.env

# Delete the .env file after creating the secret
rm .env
```

### 2. Deploy to Kubernetes

```bash
# Apply the Kubernetes configuration
kubectl apply -f llmops-k8s.yaml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services
```

### 3. Initialize Vector Store

If this is the first deployment, you need to build the vector store:

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=anime-recommender -o jsonpath='{.items[0].metadata.name}')

# Build vector store
kubectl exec -it $POD_NAME -- \
  /app/.venv/bin/python pipeline/build_pipeline.py
```

### 4. Access the Application

```bash
# Get service URL
kubectl get service anime-recommender-service

# For LoadBalancer (cloud environments)
# Access via the EXTERNAL-IP shown

# For local development with minikube
minikube service anime-recommender-service

# For port forwarding
kubectl port-forward service/anime-recommender-service 8501:80
```

## Production Considerations

### 1. Use External Vector Store

For production, consider using an external vector database:
- Hosted ChromaDB
- Pinecone
- Weaviate
- Qdrant

### 2. Image Registry

Push your image to a container registry:

```bash
# Tag for registry
docker tag anime-recommender:latest your-registry/anime-recommender:v1.0

# Push to registry
docker push your-registry/anime-recommender:v1.0

# Update llmops-k8s.yaml
# Change image: anime-recommender:latest
# To: image: your-registry/anime-recommender:v1.0
```

### 3. Scaling

Update replicas in llmops-k8s.yaml:
```yaml
spec:
  replicas: 3  # Increase for high availability
```

### 4. Resource Optimization

Adjust resources based on your needs:
```yaml
resources:
  requests:
    memory: "2Gi"    # Increase for larger models
    cpu: "1000m"
  limits:
    memory: "4Gi"
    cpu: "2000m"
```

### 5. Security

- Use Kubernetes secrets management systems (Sealed Secrets, External Secrets)
- Enable RBAC
- Use network policies
- Implement proper logging and monitoring

## Monitoring

### Check Application Health

```bash
# Check pod logs
kubectl logs -f deployment/anime-recommender

# Check pod status
kubectl describe pod -l app=anime-recommender

# Check resource usage
kubectl top pods
```

### Debugging

```bash
# Access pod shell
kubectl exec -it $POD_NAME -- /bin/bash

# Check environment variables
kubectl exec $POD_NAME -- env | grep -E "OPENAI|GROQ"

# Test connectivity
kubectl exec $POD_NAME -- curl -f http://localhost:8501/_stcore/health
```

## Cleanup

```bash
# Remove Kubernetes resources
kubectl delete -f llmops-k8s.yaml
kubectl delete secret llmops-secrets

# Remove Docker container
docker stop anime-recommender
docker rm anime-recommender
docker rmi anime-recommender:latest
```

## Troubleshooting

### Common Issues

1. **"OPENAI_API_KEY not found"**
   - Verify secret is created: `kubectl get secrets`
   - Check secret content: `kubectl get secret llmops-secrets -o yaml`

2. **Pod stuck in "Pending"**
   - Check PVC: `kubectl get pvc`
   - Check events: `kubectl describe pod $POD_NAME`

3. **Service not accessible**
   - Check service: `kubectl get svc`
   - Check endpoints: `kubectl get endpoints`

4. **High memory usage**
   - Increase resource limits
   - Use smaller embedding model
   - Implement caching

### Health Checks

The application includes health checks at `/_stcore/health`. If unhealthy:
- Check logs for errors
- Verify API keys are valid
- Ensure vector store is initialized
