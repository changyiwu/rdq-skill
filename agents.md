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
- [x] 安裝到四個 Agent，並完成分層結構、validator、SHA-256 與 UTF-8／BOM 驗證
- [ ] 在四個 Agent 完成明確觸發、模糊任務同意閘門、訪談與規格卡確認測試

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

## 三個檔案的職責（依「時效性」分家，不是依「詳細程度」）

| 檔案 | 時效 | 寫入方式 | 放什麼 |
|------|------|---------|--------|
| `handoff.md` | **只對下一個 session 有效**，過期即丟 | 每次收工整份重寫 | 做到哪、下一步、**這次**的暫時 workaround |
| `agents.md`（本檔） | **長期有效**，每個 session 都適用 | 只有規則本身變了才改 | 目標、路線圖、常設規則、結構 |
| Obsidian／`git log` | **歷史**：發生過什麼、為什麼 | 只增不刪 | 決策紀錄、踩坑完整版、逐次進度 |

驗收標準：**`handoff.md` 整份刪掉，不應損失任何長期資訊**——會的話代表該升級進本檔卻沒升級。

**本檔不要出現的東西**：❌ `## 最近進度`／逐次工作紀錄、❌ 決策理由與踩坑完整版。歷史寫 L3 筆記的〈🗓️ 最近更動紀錄〉〈🧠 決策紀錄〉〈🕳️ 踩坑筆記〉；踩過的坑只把**結論**收斂成一條祈使句寫進〈工作約定〉，原因留 L3。

## 工作約定

- 任何 Agent、任何電腦：**開工先讀 `handoff.md`，收工必更新 `handoff.md`**
- 修改共用檔案前先讀最新內容，避免覆蓋其他 Agent 的變更
- 所有回應與文件使用繁體中文
- 修改前先確認計畫，優先保留原有 RDQ 方法論、題庫與資料結構
- 跨 Agent 共用邏輯只維護一份；平台差異放在安裝或介面層，不複製四份內容
- 未經使用者明確選擇，不改動四個 Agent 的已安裝 Skill
- GitHub repo 為**公開**，不得加入金鑰、個資或未公開素材
- Windows PowerShell 5.1 會誤讀無 BOM 的 UTF-8 中文腳本，**兩支 `.ps1` 因此維持純 ASCII**，不要加中文
- **前向測試（驗證技能會不會主動提議）時，測試提示裡不可寫「Use RDQ」**，那會污染觸發條件、讓結果失去意義
