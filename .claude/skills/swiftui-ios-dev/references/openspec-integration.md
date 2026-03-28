# OpenSpec Integration Reference

This file explains how to set up and use OpenSpec for iOS development with Claude Code. OpenSpec is a spec-driven development framework — you agree on WHAT to build before writing code.

---

## What is OpenSpec?

OpenSpec adds a lightweight spec layer to AI-assisted development. Instead of jumping straight into code, you:

1. **Propose** — describe the feature, generate planning artifacts
2. **Apply** — AI writes code following those artifacts
3. **Archive** — merge specs into project knowledge, archive the change

This prevents vague prompts, scope creep, and inconsistent code.

---

## Setup: Installing OpenSpec in an iOS Project

### Step 1: Install OpenSpec CLI

```bash
# Requires Node.js 20.19.0+
npm install -g openspec

# Or use npx (no install)
npx openspec init
```

### Step 2: Initialize in Your iOS Project

```bash
cd /path/to/your-ios-project

# Interactive setup — select "claude" as your tool
openspec init

# Or non-interactive
openspec init --tools claude
```

This gives you the **core profile** with 4 commands: `propose`, `explore`, `apply`, `archive`.
This is enough for the main workflow.

### Step 2b: Enable Expanded Workflow (Optional)

If you want extra commands like `/opsx:new`, `/opsx:ff`, `/opsx:continue`, `/opsx:verify`:

```bash
# Interactive — toggle on the workflows you want
openspec config profile
# → Choose "Change workflows only"
# → Toggle ON: new, continue, ff, verify, sync, bulk-archive, onboard
# → Confirm

# Apply to your project
openspec update
```

### Available Commands by Profile

| Profile | Commands |
|---------|----------|
| **Core** (default) | `/opsx:propose`, `/opsx:explore`, `/opsx:apply`, `/opsx:archive` |
| **Expanded** (after config) | Core + `/opsx:new`, `/opsx:continue`, `/opsx:ff`, `/opsx:verify`, `/opsx:sync`, `/opsx:bulk-archive`, `/opsx:onboard` |

This creates:

```
your-ios-project/
├── openspec/
│   ├── project.md           # Tech stack, architecture rules
│   ├── AGENTS.md            # AI coding instructions
│   ├── specs/               # Living specifications
│   ├── changes/             # Active change proposals
│   └── config.yaml          # OpenSpec configuration
├── .claude/
│   └── skills/              # Claude Code slash commands
└── CLAUDE.md                # Persistent Claude Code instructions
```

### Step 3: Configure project.md

After `openspec init`, edit `openspec/project.md` with your iOS tech stack choices. Use the template from `templates/project.md` in this skill.

This is CRITICAL — project.md is how OpenSpec knows your architecture, patterns, and rules. Without it, `/opsx:propose` will generate generic specs that don't match your iOS conventions.

### Step 4: Configure CLAUDE.md

Copy the template from `templates/CLAUDE.md` in this skill to your project root. This file is read by Claude Code on EVERY session — it's your persistent coding rules.

---

## The OpenSpec Workflow for iOS

### Core Commands (Default Profile)

| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `/opsx:explore` | Investigate ideas, research patterns | Before you know what to build |
| `/opsx:propose feature-name` | Generate all planning artifacts at once | When you know what to build |
| `/opsx:apply` | AI implements from the spec artifacts | After reviewing the proposal |
| `/opsx:archive` | Merge specs, archive the change | After feature is complete |

### Expanded Commands (Expanded Profile)

| Command | What It Does |
|---------|-------------|
| `/opsx:new feature-name` | Create empty change folder |
| `/opsx:continue` | Generate next artifact step by step |
| `/opsx:ff` | Fast-forward — generate ALL remaining artifacts |
| `/opsx:verify` | Verify implementation matches spec |
| `/opsx:sync` | Sync specs with current code state |

---

## Workflow: Adding a New Module to an iOS App

Here's how to add a new feature module using OpenSpec:

### Example: Adding a Cart module to an ecommerce app

```
You: /opsx:propose add-cart-module

AI: Created openspec/changes/add-cart-module/
  ✓ proposal.md     — Cart module with add/remove/checkout
  ✓ specs/           — CartItem, Price, quantity validation scenarios
  ✓ design.md        — Coordinator + Aggregate + Repository pattern
  ✓ tasks.md         — 12 implementation tasks across Domain/Data/Presentation

Ready for implementation! Run /opsx:apply

You: (reviews proposal.md, checks design.md matches architecture)

You: /opsx:apply

AI: Implementing tasks...
  ✓ 1.1 Create Cart aggregate root
  ✓ 1.2 Create CartItem value object
  ✓ 1.3 Create CartRepository protocol
  ✓ 1.4 Create CartManagementUseCase
  ✓ 2.1 Create CartRepositoryImpl
  ✓ 2.2 Create CartDTO + CartDTOMapper
  ✓ 2.3 Create CartLocalStorage
  ✓ 3.1 Create CartState (state holder)
  ✓ 3.2 Create CartCoordinator
  ✓ 3.3 Create CartListView
  ✓ 3.4 Create CartModuleDIContainer
  ✓ 4.1 Write CartAggregateTests
All tasks complete!

You: /opsx:archive

AI: Archived to openspec/changes/archive/2026-03-23-add-cart-module/
  ✓ Specs merged into openspec/specs/
```

### Why This Works

Because `project.md` tells OpenSpec:
- "We use Coordinator Pattern + Aggregate Model"
- "Domain layer has zero framework imports"
- "State Holder named `[Name]State`, NOT ViewModel"
- "Tests use Swift Testing framework with TDD"

So when `/opsx:propose` generates `design.md`, it already knows your architecture. When `/opsx:apply` generates code, it follows your exact patterns.

---

## Workflow: Adding a Feature to an Existing Module

```
You: /opsx:propose add-discount-to-cart

AI: Created openspec/changes/add-discount-to-cart/
  ✓ proposal.md  — Add discount code functionality to Cart
  ✓ specs/       — Discount validation scenarios
  ✓ design.md    — CartDiscount value object, updated Cart aggregate
  ✓ tasks.md     — 6 tasks

You: /opsx:apply
AI: ✓ Added CartDiscount value object
    ✓ Updated Cart aggregate with applyDiscount()
    ✓ Updated CartState with discount actions
    ✓ Updated CartCheckoutView with discount field
    ✓ Added CartDiscountTests
    ✓ Updated CartModuleDIContainer

You: /opsx:archive
```

---

## Workflow: Investigating Before Proposing

When you're not sure what to build:

```
You: /opsx:explore

AI: What would you like to explore?

You: How should we handle offline mode for the product catalog?

AI: Let me investigate your codebase...
    [Analyzes existing ProductRepository, networking layer]
    
    I see 3 options:
    1. Cache-first with URLCache (simplest, fits your URLSession wrapper)
    2. Local database with SwiftData (richer queries, iOS 17+)
    3. UserDefaults+Codable (matches your Cart module's approach)
    
    Option 3 is most consistent with your existing patterns.

You: Let's go with option 3. Propose it.

You: /opsx:propose add-offline-product-cache

AI: Created proposal using option 3...
```

---

## How project.md Drives Spec Quality

The most important file is `openspec/project.md`. It should contain:

1. **Tech stack** — Swift version, iOS target, frameworks
2. **Architecture rules** — Which pattern, which layer does what
3. **Coding conventions** — Naming, access control, error handling
4. **Module structure** — Exact folder layout for new modules
5. **Testing rules** — Framework, approach, coverage targets
6. **What NOT to do** — Anti-patterns, forbidden approaches

When this is thorough, `/opsx:propose` generates specs that match your project perfectly. When it's vague, you get generic proposals that need heavy editing.

Use the `templates/project.md` template from this skill as a starting point. Fill in your tech stack choices from the skill's Step 2 developer choices menu.

---

## How CLAUDE.md Enforces Consistency

`CLAUDE.md` at the project root is read by Claude Code on every session. It contains:

1. **Architecture pattern** — So Claude never generates MVVM when you want Coordinator
2. **File naming rules** — So every file follows your conventions
3. **Layer boundaries** — So Domain never imports SwiftUI
4. **Testing rules** — So tests use the right framework

This works alongside OpenSpec's `AGENTS.md` — both files guide Claude Code, but:
- `CLAUDE.md` = always active, for ALL tasks
- `AGENTS.md` = activated by OpenSpec when running spec commands

Use the `templates/CLAUDE.md` template from this skill.

---

## Folder Structure After Full Setup

```
your-ios-project/
├── CLAUDE.md                          # Claude Code persistent rules
├── openspec/
│   ├── project.md                     # Tech stack + architecture
│   ├── AGENTS.md                      # AI spec instructions (auto-generated)
│   ├── config.yaml                    # OpenSpec config
│   ├── specs/                         # Living specs (grows over time)
│   │   ├── product/
│   │   │   └── spec.md
│   │   └── cart/
│   │       └── spec.md
│   └── changes/                       # Active changes
│       ├── add-cart-module/
│       │   ├── proposal.md
│       │   ├── specs/
│       │   ├── design.md
│       │   └── tasks.md
│       └── archive/                   # Completed changes
│           └── 2026-03-23-add-cart-module/
├── Modules/
│   ├── Product/                       # Implemented modules
│   └── Cart/
├── Shared/
├── App/
└── Tests/
```
