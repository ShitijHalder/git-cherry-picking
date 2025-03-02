# Cherry-Picking Made Easy!

Cherry-pick multiple commits at one time with no limits!

## Before You Start
Before you start, keep in mind:
- Ensure you are running the script inside the target Git repository.
- Verify you have the correct username, permissions, and access tokens.
- Double-check your source and target branch names.
- Have a backup of your repository if necessary.
- Get the Personal Access Token (PAT) from here: [https://github.com/settings/tokens](https://github.com/settings/tokens)
- Make sure you have the `git` and `curl` commands available in your terminal.
- This script is designed for GitHub repositories only.

## How to Use

1. **Clone the target repository:**
   ```bash
   git clone <your-target-repository-url>
   cd <your-target-repository-directory>
2. **Download the script using curl:**
    ```bash
   curl -O https://raw.githubusercontent.com/ShitijHalder/git-cherry-picking/main/cherry-picking.bash
3. **Make the script executable:**
     ```bash
   chmod +x cherry-picking.bash
4. **Run the script:**  
     ```bash    
     ./cherry-picking.bash
5. **Follow the prompts:**
   The script will prompt you for the necessary input parameters:
   - Source repository URL
   - Target repository URL
   - Source branch
   - Target branch
   - Commit list (full hashes, comma-separated)
   - Git username
   - Git personal access token
6. **Wait for the process to complete:**
      This may take a few seconds depending on the number of commits and size of your repository.

7. **And Voilà, you're done!**
      Your due cherry-picks are now done, my guy. Let us move on to the next task, shall we?  
