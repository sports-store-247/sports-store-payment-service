# sports-store-payment-service

FastAPI microservice simulating payment processing for the Sports Store platform.
Owns the `payment_db` MongoDB database. Called by `order-service` during order
finalization.

## Stack

FastAPI, MongoDB (Motor), pytest.

## Local development

```bash
cp .env.example .env
pip install -r requirements.txt
uvicorn main:app --reload
```

Health check: `GET /health`.

## Branching convention

- `feature/<short-description>` — new functionality
- `bugfix/<short-description>` — non-urgent fixes
- `hotfix/<short-description>` — urgent production fixes

All changes land on `main` via pull request with at least 1 approval (enforced by repository ruleset).
