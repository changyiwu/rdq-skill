# RDQ Method — 需求探索四象限法

**Requirements Discovery Quadrant Method**

一套可供 Claude Code、Codex、OpenCode、AntiGravity 共用的需求訪談 Skill。

> 在執行之前，先把真正的問題找出來。

---

## 這是在解決什麼問題

你請 AI 做一份東西，它做出來了——格式完整、邏輯通順，但**不能用**。

AI 沒有做錯任何被交代的事。問題是：**有太多事，根本沒有被交代。**

常見解法是教使用者寫更完整的提示詞，但人本來就不知道自己漏了什麼。RDQ 換一個方向：**讓 Agent 在動手之前，先協助使用者把需求挖出來。**

---

## 四象限

| 象限 | 英文 | 使用者的狀態 | Agent 該做的事 |
|---|---|---|---|
| **Ⅰ** | Known Knowns | 已經明說的目標與限制 | **擷取**、回顯、確認 |
| **Ⅱ** | Known Unknowns | 知道自己不懂、會主動問 | **解答**、查詢、澄清 |
| **Ⅲ** | Unknown Knowns | 知道卻沒想到要說 | **訪談**、追問 |
| **Ⅳ** | Unknown Unknowns | 完全沒想過的選項或風險 | **主動端出**建議、替代方案與代價 |

關鍵判別只有一句：

> **使用者現在當場答得出來嗎？**

- 答得出來 → 象限Ⅲ，用問的。
- 要先給資訊才能判斷 → 象限Ⅳ，用菜單端給他選。

問使用者「你還有什麼沒想到的嗎？」是邏輯錯誤——他答得出來就不叫 Unknown Unknowns。

---

## 支援的 Agent

同一份 runtime 內容安裝到四個位置，不維護四個 fork：

| Agent | Windows Skill 目錄 |
|---|---|
| Claude Code | `%USERPROFILE%\.claude\skills\rdq` |
| Codex | `%USERPROFILE%\.agents\skills\rdq` |
| OpenCode | `%USERPROFILE%\.config\opencode\skills\rdq` |
| AntiGravity | `%USERPROFILE%\.gemini\config\skills\rdq` |

跨 Agent 相容原則：

- 不寫死 `AskUserQuestion`、`WebSearch` 等工具名稱。
- 優先使用目前 Agent 的原生結構化提問、搜尋與瀏覽能力。
- 原生結構化提問不可用時，退回編號文字問題。
- 優先讀取 `AGENTS.md`／`AGENTS.md` 與 `handoff.md`；Agent 專屬指令檔只補增量資訊。
- 交棒前盤點目前可用能力，不假設特定下游 Skill 已安裝。

---

## 安裝

### PowerShell 安裝腳本

先預覽，不寫入任何 Agent 目錄：

```powershell
./scripts/install-four-agents.ps1 -WhatIf
```

確認後安裝四個 Agent：

```powershell
./scripts/install-four-agents.ps1 -Force
```

只安裝單一 Agent：

```powershell
./scripts/install-four-agents.ps1 -Agent Codex -Force
```

腳本只複製 runtime 必需內容：

```text
rdq/
├── SKILL.md
└── references/
    ├── question-bank.md
    └── spec-template.md
```

README、LICENSE、Git metadata、`AGENTS.md`、`handoff.md`、`CLAUDE.md` 與安裝腳本都留在來源專案，不會混進已安裝 Skill。

### 驗證來源

```powershell
./scripts/validate-skill.ps1
```

驗證項目包含必要檔案、UTF-8 BOM、YAML frontmatter、名稱、平台硬綁定、參考檔連結與 `SKILL.md` 行數。

---

## 使用

不需要記指令，直接說：

```text
用 RDQ
```

其他觸發說法包括：

- 先訪談我再做
- 幫我釐清需求
- 我還沒想清楚要什麼
- 幫我想想還缺什麼
- 做需求規格

丟一個資訊不足的中大型任務時，Agent 只會先問一次「要不要跑 RDQ？」；你說不用，這段對話就不再提議。

### 你會經歷什麼

1. Agent 回顯你已說的內容與可讀的專案脈絡。
2. 問少量會影響返工成本的選項題。
3. 端出 3–5 條你可能沒想到的建議，每條標示代價。
4. 產出一張一個螢幕能看完的需求規格卡。
5. 你明確確認後才執行或交棒。

| 模式 | 適用情境 | 最多打擾次數 |
|---|---|---|
| Lite | 單一成品、半天內做得完 | 2 次 |
| Full | 多產出、跨天、公開、花錢或不可逆 | 3 次 |

Full 最多兩輪訪談；象限Ⅳ建議菜單併入最後一輪，另有一次規格卡確認，因此上限仍是三次。

### 不會觸發的情況

- 小任務或單一檔案修改
- 需求已完整
- 使用者說「直接做」「不用問」
- 純查詢或知識問答
- 執行中任務的追加調整
- 開工、收工、專案初始化等既有流程
- 正在製作 RDQ 方法論的簡報、文章、影片或教材
- 另一個自帶訪談流程的 Skill 正在進行

---

## 題庫與領域

`references/question-bank.md` 內建六個領域：

- 教育研習／演講
- 教學簡報／投影片
- 備課教材／課程設計
- 影片內容／YouTube
- 程式／網頁專案
- 通用 fallback

題庫找不到對應領域時，Agent 以通用八維度為骨架，依紅黃綠燈與Ⅲ／Ⅳ判別測試現場生題，不會硬套教學情境。

題庫是活文件。新增領域時，Ⅲ訪談題只收「答案不同會導致重做」的紅燈題；Ⅳ建議從不可逆決定、法遵與資安紅線、常見失敗原因三處找料，每條都要標代價。

---

## 設計重點

| 機制 | 解決的問題 |
|---|---|
| 象限動詞鎖定 | 防止退化成一直追問的 chatbot |
| 回顯代替提問 | 已知資訊不重問 |
| 假設顯性化 | 把沒問到的內容攤在規格卡上 |
| 紅黃綠燈 | 只問答錯會重做的問題 |
| 零題坍縮 | 資訊已齊就直接出規格卡 |
| 互動預算硬上限 | 控制訪談成本 |
| 逃生口常設 | 使用者隨時可喊停 |
| `status` 閘門 | `draft → confirmed`，未確認不得執行 |

---

## 專案結構

```text
rdq-skill/
├── rdq/                        # Skill 本體，安裝時整包複製
│   ├── SKILL.md
│   └── references/
│       ├── question-bank.md
│       └── spec-template.md
├── scripts/
│   ├── install-four-agents.ps1
│   └── validate-skill.ps1
├── AGENTS.md
├── handoff.md
├── CLAUDE.md
├── README.md
└── LICENSE
```

`SKILL.md` 保留核心流程；題庫與規格卡細節放在 `references/`，只在需要時載入。安裝腳本只配送 runtime 必需檔案。

Skill 本體集中在 `rdq/`，與專案基礎建設（README、LICENSE、`AGENTS.md`、`handoff.md`、`CLAUDE.md`、`scripts/`）分層。這樣「整個資料夾複製」就等於正確安裝，通用的技能同步工具不必個別知道哪些檔案該排除；資料夾名 `rdq` 也與 `SKILL.md` 的 `name:` 一致。

---

## 原創性與目前狀態

RDQ Method 不宣稱創造 Known／Unknown 知識分類或需求工程理論。它是一套整合型、實驗性的實務框架，把既有概念重新詮釋並流程化，用於 AI Agent、AI Skill 與 AI 專案的前期需求建構。

Known／Unknown 三分類因 Donald Rumsfeld 2002 年公開談話而廣為人知，更早已見於風險分析、決策與航太領域；Unknown Knowns 由後續哲學與知識管理討論補入；流程面則來自 Requirements Engineering 中的 Requirements Elicitation。

規格卡的 `telemetry` 是單臂描述性資料，沒有對照組，不可宣稱 RDQ 已降低特定比例的修改次數。AI 也無法真正判定使用者「知不知道自己知道」；「當場答得出來與否」只是操作型近似。

---

## 授權

MIT License。作者：[mathruffian-dot](https://github.com/mathruffian-dot)
