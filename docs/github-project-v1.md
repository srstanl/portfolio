# GitHub Project v1 Setup (Execution Board)

## Purpose
Stand up one execution-focused GitHub Project for `srstanl/portfolio` using an Epic + Task model.

## Create Project
In GitHub UI:
1. Go to `Projects`.
2. Create new project.
3. Set:
   - Name: `Portfolio Execution Board`
   - Description: `Near-term execution tracking for DevEx Platform Portfolio`
   - Visibility: `Private` (move to public later if desired)

## Add Custom Fields
Create these fields in the project:

1. `Type` (Single select)
- `Epic`
- `Task`
- `Decision`
- `Risk`

2. `Priority` (Single select)
- `P0`
- `P1`
- `P2`

3. `Area` (Single select)
- `CI`
- `CD`
- `IDP`
- `Templates`
- `Docs`
- `Backstage`
- `Security`

4. `Status` (Single select)
- `Inbox`
- `Ready`
- `In Progress`
- `Blocked`
- `Review`
- `Done`

5. `Target` (Single select)
- `Now`
- `Next`
- `Later`

6. `Due` (Date)
7. `Owner` (Assignees)

## Define Views
### View 1: Execution Board (Kanban)
- Layout: Board
- Group by: `Status`
- Filter: `Target = Now OR Target = Next`
- Sort: `Priority` ascending, then `Due` ascending

### View 2: Epics
- Layout: Table or Board
- Filter: `Type = Epic`
- Group by: `Area`

### View 3: Risks & Decisions
- Layout: Table
- Filter: `(Type = Risk OR Type = Decision) AND Status != Done`

### View 4: Done Log
- Layout: Table
- Filter: `Status = Done`
- Sort: `Updated` descending

## Seed Initial Items
Create these **Epics**:
- `Epic: Stabilize Angular quality lane`
- `Epic: Backstage repo boundary decision`
- `Epic: First CD implementation`
- `Epic: Paved-roads extraction after CD`

Create these **child tasks/items**:

### Under `Epic: Stabilize Angular quality lane`
- `Task: Commit Playwright E2E smoke config and CI step`
- `Task: Ensure web-angular-ci is green on main`

### Under `Epic: Backstage repo boundary decision`
- `Decision: Keep backstage-portal in this repo vs split repo`
- `Task: Document rationale in README/PROJECT_CONTEXT`

### Under `Epic: First CD implementation`
- `Task: Define provider-agnostic deployment contract`
- `Task: Implement preview + manual promote lane for python-service`

### Under `Epic: Paved-roads extraction after CD`
- `Task: Extract reusable CD workflow skeleton`
- `Task: Add paved-roads README section for deployment standards`

## Default Operating Rules
- New item defaults:
  - `Status=Inbox`
  - `Priority=P1`
  - `Target=Next`
- Move to `Ready` only when acceptance criteria are present in item body.
- `In Progress` requires an assignee.
- `Done` requires linked PR/commit or evidence note.
- `Risk` requires mitigation owner and mitigation date.

## Validation Checklist
1. Project exists with correct name/description.
2. All 7 custom fields exist and are editable.
3. All 4 views exist with correct filters/grouping.
4. Seed epics/tasks appear in `Execution Board` view.
5. Move one task across statuses to verify workflow.
6. Add one `Risk` item and confirm it appears in `Risks & Decisions` view.

## Optional Next Step
Install `gh` CLI later and automate seeding/project updates.
