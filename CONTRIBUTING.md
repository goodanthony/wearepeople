## Branching Strategy

### 1. Branch Naming
Format: `type/description-of-change`

* **Features:** `feat/add-user-profile`
* **Fixes:** `fix/prevent-header-overflow`
* **Chores:** `chore/upgrade-dependencies`
* **Docs:** `docs/update-setup-guide`

### 2. Workflow
1.  **Sync:** Always pull `main` before creating your branch.
2.  **Commit:** Write clear, concise commit messages.
3.  **PR:** Open a Pull Request against `main`.
    * *Tip:* If the work is still in progress, mark the PR as "Draft".
4.  **Merge:** We use **Squash and Merge** to maintain a linear history on the main branch.

### 3. Definition of Done
* CI/Tests must pass.
* Code has been reviewed by at least one other team member.
* Local verification is complete.
