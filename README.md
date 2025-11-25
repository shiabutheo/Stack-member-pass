StackMemberPass – On-Chain Membership Pass Smart Contract

StackMemberPass is an on-chain membership management smart contract built on the Stacks blockchain using Clarity.  
It enables decentralized issuance, verification, and revocation of membership passes for DAOs, communities, gated platforms, and subscription-based applications.

---

Features

- **On-chain membership verification**  
  Easily check if a user holds a valid membership pass.

- **Secure pass issuance**  
  Only authorized administrators can mint new membership passes.

- **Pass revocation**  
  Admins can revoke passes at any time, fully on-chain.

- **Metadata support**  
  Each membership pass can include customizable metadata (e.g., level, tag, or tier).

- **Audit-friendly event logs**  
  Emitted logs ensure full transparency for pass issuance and revocation.

- **Permissioned access**  
  Admin-only functions to prevent unauthorized operations.

---

Contract Functions

**Public Functions**
- `issue-pass` – Issues a membership pass to a specified user.  
- `revoke-pass` – Revokes a member’s pass.  
- `update-pass-metadata` – Changes metadata associated with a pass.

**Read-Only Functions**
- `check-member` – Returns `true` if a user has an active membership pass.  
- `get-pass-metadata` – Fetches pass metadata for a member.  
- `is-admin` – Checks whether a principal is an authorized admin.

**Administrative Functions**
- `add-admin` – Adds a new admin principal.  
- `remove-admin` – Removes an existing admin.

---

How It Works

1. **Admins issue passes** using `issue-pass`.  
2. Passes are stored in a data map linking principals to pass metadata.  
3. DApps can call `check-member` to gate access.  
4. Admins can modify or revoke passes at any point.  
5. Event logs record all critical actions for transparency.

---

 Use Cases

- DAO membership verification  
- Token-free access passes  
- Subscription validation  
- Gated educational platforms  
- Exclusive content/member-only tools  
- Community credentialing systems  

---

Deployment

1. Clone the repository.  
2. Ensure you have **Clarinet** installed.  
3. Run tests and check contract validity:

   ```bash
   clarinet check
