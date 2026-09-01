# Work Nihongo (jpschool)

このリポジトリは「しごと日本語 / Work Nihongo」MVPの実装です。

## 参照文書

- `SPEC.md`: 要件、受入条件、基本設計の正本
- `TASKS.md`: 20営業日の実装タスクと進捗
- `AGENTS.md`: Codexと開発者が守るプロジェクトルール
- `docs/decisions.md`: 重要な設計判断

## セットアップ

Rubyは `.ruby-version` に合わせて `3.3.9` を使用します。現在のモック画面の閲覧だけならPostgreSQLなしで起動できます。DB機能や `bin/setup` を使う場合は、PostgreSQLをローカルまたはDocker Composeで用意してください。

```sh
rbenv install 3.3.9
bin/setup
```

## 開発環境

現在確認しているローカル開発環境は次の通りです。

- OS: macOS
- Ruby: 3.3.9
- Rails: 8.1.3.1
- Bundler: 2.7.1
- Node.js: v14.21.3
- Yarn: 1.22.19
- Database: PostgreSQL想定
- Frontend: Hotwire / Turbo / Stimulus / Tailwind CSS

この端末ではDocker CLIは未インストールです。Dockerで動作確認する場合は、別途Docker Desktopなどを用意してください。

## Git

- リポジトリ: `https://github.com/ytimesy/jpschool.git`
- デフォルトブランチ: `main`
- リモート名: `origin`

通常の反映手順:

```sh
git status
git add .
git commit -m "変更内容の要約"
git push origin main
```

## 起動

```sh
bin/dev
```

Dockerで確認する場合:

```sh
docker compose up --build
```

## デプロイ

現在のデプロイ先は Google Cloud Run です。

- Google Cloud project: `web-serv-493701`
- Service: `jpschool`
- Region: `europe-west1`
- Public URL: `https://jpschool-7cobj7xvjq-ew.a.run.app`
- Latest verified revision: `jpschool-00011-hut`

手動デプロイ例:

```sh
gcloud run deploy jpschool \
  --project web-serv-493701 \
  --region europe-west1 \
  --source . \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars RAILS_ENV=production,RAILS_SERVE_STATIC_FILES=true,RAILS_LOG_TO_STDOUT=true,SECRET_KEY_BASE="$(bin/rails secret)"
```

`SECRET_KEY_BASE` は本番環境の秘密情報です。リポジトリには保存せず、Cloud Runの環境変数として設定してください。

## 確認コマンド

現在の実装段階では、Minitestと教材検証の足場があります。RuboCop、Brakeman、bundler-auditはまだGem未導入です。

```sh
bin/rails db:prepare
bin/rails test
bin/rails test:system
bundle exec rubocop
bundle exec brakeman -q
bundle exec bundler-audit check --update
bin/rails content:validate
```

## 現在の状態

Railsの最小構成と、学習者向け・管理者向けの画面モックがあります。表示言語は日本語、英語、ベトナム語、中国語に対応しています。

GAP-01対応の土台として、教材DBモデル、教材YAML、`content:validate`、Minitestのモデル/サービス検証を追加しています。認証、教材インポート、復習回答履歴、進捗集計の本実装は今後のGAPで対応します。
