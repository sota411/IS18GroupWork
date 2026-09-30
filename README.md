# IS18 Group Work

授業のグループワーク用リポジトリ。

## スケジュール

9/30〜11/04 の詳細ガントチャートは [docs/gantt.md](docs/gantt.md) を参照。

## タスク管理

GitHub Projects を使って、Issue をそのままタスクとして管理する。

推奨ビュー:

- **Board**: Todo / In Progress / Done
- **Roadmap**: Start date / Target date を使ったガントチャート風表示
- **Table**: 担当者・優先度・期間を一覧確認

## 推奨フィールド

| Field | Type | 値 |
|---|---|---|
| Status | Single select | Todo / In Progress / Done |
| Priority | Single select | High / Medium / Low |
| Start date | Date | 開始日 |
| Target date | Date | 終了予定日 |
| Assignees | Assignees | 担当者 |

## Issue の運用

1. 作業は原則 Issue にする
2. 1 Issue = 1つの成果物または確認可能な作業
3. 着手時に Status を In Progress にする
4. PR を Issue に紐づける
5. 完了したら Issue を close する

## 最初に作る Project

Project 名: **IS18 Group Work**

作成後、以下の Issue を Project に追加して Roadmap 表示にする。

- 要件定義
- 画面・機能設計
- DB / データ設計
- 実装
- 結合テスト
- 発表・提出準備
