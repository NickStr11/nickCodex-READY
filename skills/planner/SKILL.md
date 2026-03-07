---
name: planner
description: >
  Create comprehensive, phased implementation plans with sprints and atomic tasks.
  Use when user says: "make a plan", "create a plan", "plan this out", "plan the implementation",
  "help me plan", "design a plan", "draft a plan", "write a plan", "outline the steps",
  "break this down into tasks", "what's the plan for", or any similar planning request.
  Also triggers on explicit "/planner" or "/plan" commands.
---

# Planner Agent

Create detailed, phased implementation plans for bugs, features, or tasks.

## Process

### Phase 0: Research

1. **Investigate the codebase:**
   - Architecture and patterns
   - Similar existing implementations
   - Dependencies and frameworks
   - Related components

2. **Analyze the request:**
   - Core requirements
   - Challenges & edge cases
   - Security/performance/UX considerations

### Phase 1: Clarify Requirements

Before doing any documentation search, clarify requirements with the user when needed.
This should narrow the problem, not create friction.

Think of the minimum focused questions needed to reduce risk. Prefer 0-3 questions, not an interrogation.

Suggested categories:
1. Goals and success criteria
2. Scope and non-goals
3. Users and core workflows
4. Platforms and environments
5. Tech constraints
6. Data and integrations
7. Auth and permissions
8. Performance and reliability
9. Testing and validation

If the user already wants to move fast and the gaps are tolerable, make reasonable assumptions and state them inside the plan instead of blocking on more questions.

### Phase 2: Retrieve Documentation

When the plan involves any external library, API, framework, or service, use the `context7` skill to fetch the latest official docs before drafting tasks. This keeps the plan version-accurate and reduces stale advice.

### Phase 3: Create Plan

#### Structure

- **Overview**: Brief summary and approach
- **Sprints**: Logical phases that build on each other
- **Tasks**: Specific, actionable items within sprints

#### Sprint Requirements

Each sprint must:
- Result in a demoable, runnable, testable increment
- Build on prior sprint work
- Include a demo or verification checklist

#### Task Requirements

Each task must be:
- Atomic and committable
- Specific with clear inputs and outputs
- Independently testable
- Clear about file paths when relevant
- Clear about dependencies for parallel execution
- Clear about tests or validation

**Bad:** "Implement Google OAuth"

**Good:**
- "Add Google OAuth config to env variables"
- "Install passport-google-oauth20 package"
- "Create OAuth callback route in src/routes/auth.ts"
- "Add Google sign-in button to login UI"

### Phase 4: Save

Save the file.

Generate filename from request:
1. Extract keywords
2. Convert to kebab-case
3. Add a -plan.md suffix

Example:
- "fix xyz bug" -> xyz-bug-plan.md

### Phase 5: Gotchas

After saving, identify potential issues and edge cases in the plan. Address them proactively.

If there are unresolved gotchas, stop and ask up to 3 more focused questions directly.

Refine the plan if any additional useful info is provided.

## Plan Template

```markdown
# Plan: [Task Name]

**Generated**: [Date]
**Estimated Complexity**: [Low/Medium/High]

## Overview
[Summary of task and approach]

## Prerequisites
- [Dependencies or requirements]
- [Tools, libraries, access needed]

## Sprint 1: [Name]
**Goal**: [What this accomplishes]
**Demo/Validation**:
- [How to run/demo]
- [What to verify]

### Task 1.1: [Name]
- **Location**: [File paths]
- **Description**: [What to do]
- **Dependencies**: [Previous tasks]
- **Acceptance Criteria**:
  - [Specific criteria]
- **Validation**:
  - [Tests or verification]

### Task 1.2: [Name]
[...]

## Sprint 2: [Name]
[...]

## Testing Strategy
- [How to test]
- [What to verify per sprint]

## Potential Risks & Gotchas
- [What could go wrong]
- [Mitigation strategies]

## Rollback Plan
- [How to undo if needed]
```

## Important

- Think about the full lifecycle: implementation, testing, deployment
- Consider non-functional requirements
- Show the user a short summary and the file path when done
- Do not implement anything while using this skill
