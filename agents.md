# RDQ 通用需求探索 Skill（專案藍圖）

> 本檔為跨 Agent 通用的專案藍圖（AGENTS.md 開放標準）。任何 Agent 的每個 session 都應先讀本檔＋`handoff.md`。
> Claude Code 不讀 `agents.md`，改由 `CLAUDE.md` 的 `@agents.md` import 本檔；Claude 專屬規範寫在 `CLAUDE.md`。

## 專案簡介

本專案維護 RDQ Method（需求探索四象限法）Skill。現階段目標是保留既有方法論與題庫，將原本偏向 Claude Code 的版本改造成可由 Claude Code、Codex、OpenCode、AntiGravity 共用的跨 Agent 版本。

## 關鍵時程

目前無固定時程。

## 目標與路線圖

- [x] 盤點既有 RDQ Skill、題庫與需求規格卡模板
- [x] 完成跨 Agent 專案初始化
- [x] 將平台專屬工具名稱改為能力導向描述
- [x] 建立四 Agent 共用的安裝與驗證流程
- [ ] 安裝到四個 Agent 並完成觸發、訪談與確認閘門測試

## 資料夾結構

```text
rdq-skill/
├── agents.md
├── handoff.md
├── CLAUDE.md
├── README.md
├── LICENSE
├── .gitignore
├── rdq/                        # Skill 本體（資料夾名 ＝ SKILL.md 的 name:）
│   ├── SKILL.md
│   └── references/
│       ├── question-bank.md
│       └── spec-template.md
└── scripts/
    ├── install-four-agents.ps1
    └── validate-skill.ps1
```

Skill 本體集中在 `rdq/`，與專案基礎建設分層——「整包複製 `rdq/`」就等於正確安裝，通用同步工具不必個別知道要排除 `.git/`、`README.md` 等檔案。

## 同步層級（本專案初始化至第 3 層級）

| 層級 | 平台 | 位置 | 讀取時機 |
|------|------|------|---------|
| L1 | 本地（GDrive） | `agents.md`＋`handoff.md`＋`CLAUDE.md`（橋接） | 每個 session |
| L2 | GitHub | `https://github.com/changyiwu/rdq-skill`（公開） | 指定時 |
| L3 | Obsidian | `rdq-skill/專案工作流程.md` | 有需要時 |

## 工作約定

- 任何 Agent、任何電腦：**開工先讀 `handoff.md`，收工必更新 `handoff.md`**
- 修改共用檔案前先讀最新內容，避免覆蓋其他 Agent 的變更
- 所有回應與文件使用繁體中文
- 修改前先確認計畫，優先保留原有 RDQ 方法論、題庫與資料結構
- 跨 Agent 共用邏輯只維護一份；平台差異放在安裝或介面層，不複製四份內容
- 未經使用者明確選擇，不改動四個 Agent 的已安裝 Skill
