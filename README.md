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

## 起動

```sh
bin/dev
```

Dockerで確認する場合:

```sh
docker compose up --build
```

## 確認コマンド

現在の実装段階ではテストと品質ツールの足場は未整備です。Day 2の完了条件として、次のコマンドが実在し成功する状態へ揃えます。

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

Railsの最小構成と学習者向けモック画面があります。認証、DBモデル、管理画面、教材インポート、自動テストは未実装です。
