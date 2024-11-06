import os
import subprocess

def upload_to_github(repo_name, local_path, commit_message):
    # Check if the local path exists
    if not os.path.exists(local_path):
        print(f"The specified path {local_path} does not exist.")
        return

    # Navigate to the local repository path
    os.chdir(local_path)

    # Initialize the Git repository if it is not already initialized
    if not os.path.exists(os.path.join(local_path, '.git')):
        subprocess.run(['git', 'init'], check=True)
        print("Initialized a new Git repository.")

    # Set the remote repository URL
    remote_url = f'https://github.com/your_username/{repo_name}.git'
    subprocess.run(['git', 'remote', 'add', 'origin', remote_url], check=True)

    # Stage all changes
    subprocess.run(['git', 'add', '.'], check=True)
    print("Added files to the staging area.")

    # Commit the changes
    subprocess.run(['git', 'commit', '-m', commit_message], check=True)
    print(f"Committed changes with message: '{commit_message}'")

    # Push to the remote repository
    subprocess.run(['git', 'push', '-u', 'origin', 'main'], check=True)
    print("Changes pushed to GitHub.")

if __name__ == "__main__":
    # Parameters to customize
    repo_name = 'your_repo_name'  # Replace with your GitHub repository name
    local_path = 'path/to/your/as400/source'  # Path to your AS400 source code
    commit_message = 'Initial commit of AS400 source code'  # Commit message

    upload_to_github(repo_name, local_path, commit_message)
