# Git命令总结

- 删除远程branch和tag

	> git push origin --delete <branchName>
	> git push origin --delete tag <tagname>

- 删除本地branch

	> git branch -d yourBranch

- 新建分支

	> git checkout -d newBranch
	
- 切换分支

	> git checkout otherBranch
	
	PS : 在切换前, 最好commit掉当前正在处理的项目,切换后, git 会重置工作目录, 回到otherBranch的最后一次提交时的状态
	
- 合并分支

	> git checkout master // 回到主分支
	> git merge yourBranch 
	
- 查看当前分支

	> git branch
	> git branch --merged
	> git branch --no-merged