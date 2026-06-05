# Веса модели

Файл `model.safetensors` (~470 МБ) не хранится в Git — он в `.gitignore`.

## Локально

Веса должны лежать рядом с этим файлом:

```
ml_service/resume_model_v2_epoch_3/model.safetensors
```

## Для сдачи проекта (если нужен репозиторий с весами)

Вариант 1 — Git LFS:

```bash
git lfs install
git lfs track "ml_service/resume_model_v2_epoch_3/model.safetensors"
git add .gitattributes
```

Вариант 2 — приложить архив с весами отдельно к сдаче.
