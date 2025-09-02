# 🔐 Kubernetes Secrets Security Guide

## ⚠️ CRITICAL: Never Commit Real API Keys!

This guide explains how to safely handle secrets in Kubernetes without exposing them in Git.

## 🚨 The Problem

If you put real API keys in `llmops-k8s.yaml` and push to GitHub:
- **Anyone can see your keys** (even in private repos, if someone gains access)
- **Keys can be found in Git history** (even if you delete them later)
- **Bots scan GitHub for API keys** and will find and abuse them
- **You might get charged** for unauthorized API usage

## ✅ The Safe Approach

### Step 1: No Secrets in Git

The `llmops-k8s.yaml` file does NOT contain any secrets section at all. This ensures you can never accidentally commit API keys.

### Step 2: Create Real Secrets in Your Cluster

Use one of these methods:

#### Option A: Direct Command (Simplest)
```bash
kubectl create secret generic llmops-secrets \
  --from-literal=OPENAI_API_KEY='sk-proj-your-real-key' \
  --from-literal=GROQ_API_KEY='gsk_your-real-key'
```

#### Option B: From Environment File
```bash
# Create temporary .env file
echo "OPENAI_API_KEY=sk-proj-your-real-key" > .env
echo "GROQ_API_KEY=gsk_your-real-key" >> .env

# Create secret
kubectl create secret generic llmops-secrets --from-env-file=.env

# IMPORTANT: Delete the file immediately!
rm .env
```

### Step 3: Deploy Your Application

Deploy using the main Kubernetes configuration:
```bash
kubectl apply -f llmops-k8s.yaml
```

## 🎯 Best Practices

### For Development
1. Use `.env` files locally (never commit them)
2. Add `.env` to `.gitignore`
3. Share keys through secure channels (password managers, encrypted messages)

### For Teams
1. Use a secrets management tool:
   - **Sealed Secrets**: Encrypt secrets that can be stored in Git
   - **External Secrets**: Sync from AWS/Azure/GCP secret stores
   - **HashiCorp Vault**: Enterprise secret management

2. Document which secrets are needed:
   ```markdown
   ## Required Secrets
   - OPENAI_API_KEY: Get from https://platform.openai.com/api-keys
   - GROQ_API_KEY: Get from https://console.groq.com/keys
   ```

### For Production
1. Use cloud provider secret management:
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Secret Manager

2. Set up RBAC to limit who can read secrets

3. Rotate keys regularly

## 🔍 How to Check Your Secrets

```bash
# List secrets
kubectl get secrets

# Verify secret exists (doesn't show values)
kubectl describe secret llmops-secrets

# Decode secret (only if you need to verify)
kubectl get secret llmops-secrets -o jsonpath='{.data.OPENAI_API_KEY}' | base64 -d
```

## 🚫 What NOT to Do

```bash
# DON'T edit the YAML with real keys
vim llmops-k8s.yaml  # Then add real keys ❌

# DON'T commit files with keys
git add secrets.yaml  # With real keys ❌

# DON'T share keys in plain text
echo "My key is sk-proj-..." # In Slack/Email ❌
```

## 🛡️ If You Accidentally Commit Keys

1. **Immediately revoke the keys** in OpenAI/Groq dashboard
2. **Remove from Git history** (not just delete the file)
3. **Generate new keys**
4. **Check for unauthorized usage**

## 📚 Additional Resources

- [Kubernetes Secrets Documentation](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Sealed Secrets](https://sealed-secrets.netlify.app/)
- [External Secrets Operator](https://external-secrets.io/)

Remember: **Security is everyone's responsibility!**
