# 担当2(Chrome拡張・Jev)開発メモ

企画書(docs/proposal.md)のコア機能B「マイページ登録フォームへの自動入力」を担当する。
このメモは役割分担の相談内容をまとめたもの。AGENTS.md や .github/ のルールと食い違う場合はそちらを優先する。

## チームの役割分担(3人)

| 担当 | 領域 | 主な作業 |
|---|---|---|
| 担当1 | バックエンド・Gmail(コア機能A) | Google OAuth, Gmail取得・解析・差分同期, DB, 利用者ごとのデータ分離, 連携解除・削除 |
| 担当2(自分) | Chrome拡張・Jev(コア機能B) | フォーム項目の取得, Jevによる対応付け, 値の入力, 未入力項目の表示 |
| 担当3 | フロント・検証・PM | 初回連携・企業一覧・プロフィール画面, テスト用メール/フォーム, 利用者評価, 提出物 |

## リポジトリ構成(案, TypeScriptモノレポ)

```
apps/
  web/                 # 担当3
  api/                 # 担当1
    src/jev/           # 担当2: Jevへの問い合わせ
  extension/           # 担当2: Chrome拡張 (Manifest V3)
packages/
  shared/              # 3人共通: プロフィール項目一覧・型定義
fixtures/
  emails/              # 担当3
  forms/               # テストフォーム
docs/
```

### apps/extension

```
manifest.json
src/
  background/index.ts     # 実行ボタン → content script注入 → API呼び出しの仲介
  content/
    extractFields.ts      # フォーム項目の取得(ラベル・type・選択肢)
    resolveLabel.ts       # label要素, aria-label, placeholder, 近くの文字からラベル推定
    fillFields.ts         # ネイティブsetterで値を設定し input/change イベントを発火
    highlight.ts          # 入力済み・未入力項目の色分け
  popup/index.html, main.ts  # 「自動入力」ボタンと結果一覧
  lib/apiClient.ts        # バックエンド通信
```

- content scriptは常駐させず, `activeTab` + `chrome.scripting.executeScript` でボタン押下時だけ注入する.
- 最終送信, 利用規約への同意, パスワード設定, CAPTCHA, メール認証は行わない.

### apps/api/src/jev

```
route.ts        # POST /api/autofill/mapping
buildRequest.ts # 項目情報 + プロフィール項目の説明 → Jev入力
parseResult.ts  # Jev結果 → 項目ごとの対応(不確かなら "none")
fallback.ts     # Jevが使えないときのラベル辞書による対応付け
```

- Jevにはプロフィールの実値を送らない. ラベル・形式とプロフィール項目の説明だけを送る.
- Jevは文章生成モデルではなく, 候補から構造化された判断を返すモデル. 各フォーム項目に ProfileFieldKey か "none" を選ばせる.

### packages/shared(10/08にチームで確定)

- `profileFields.ts`: プロフィール項目の一覧(key・日本語名・説明). `ProfileFieldKey = keyof PROFILE_FIELDS | "none"`
- `autofill.ts`: `FieldDescriptor`, `MappingResult` などの型

## 処理の流れ

popup 自動入力ボタン → background が content script 注入 → extractFields → api/jev で対応付け
→ プロフィールAPIから値取得 → fillFields + highlight → popup に「入力済み N件 / 要手入力 M件」

## 実装順(Issue単位, ラベル core-B)

1. ルート構成(ワークスペース, packages/shared) ※3人のうち1人が先に作ってmainへ — 10/08
2. 拡張の雛形. chrome://extensions で読み込めること — 10/08
3. fixtures/forms/form-a.html(氏名・ふりがな・メール・学校名・都道府県select) — 10/08
4. extractFields / resolveLabel. 項目一覧がコンソールに出る — 10/09
5. fillFields(固定の対応表 + ダミープロフィール). 送信しない — 10/09
6. fallback(ラベル辞書). 項目名の違う form-b でも主要項目が入る — 10/10
7. Jev API接続. 使えなければ fallback で代用 — 10/10〜11
8. 担当1のプロフィールAPIと接続 — 10/12〜14
9. 色分けとポップアップの結果表示 — 10/12

## 作業ルール

- mainに直接pushしない. `feature/...` ブランチ → PR(`Closes #番号`)→ 他の担当がレビュー.
- `packages/shared` を変更するときはPRで全員に知らせる.
- APIキーや認可トークンをソースコードに埋め込まない.

## 10/08に決めること

1. npm か pnpm か, バックエンドのフレームワーク
2. packages/shared のプロフィール項目一覧と autofill の型
3. 拡張からAPIへの認証方法(Webアプリのログイン状態の引き継ぎ)
