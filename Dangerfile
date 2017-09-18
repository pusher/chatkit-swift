# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Run SwiftLint
swiftlint.lint_files

# Warn when there are merge conflicts in the diff
if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
  warn 'Please rebase to get rid of the merge commits in this PR'
end
