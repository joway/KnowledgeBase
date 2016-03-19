# Shiro 学习笔记

介绍:Shiro 不会去维护用户、维护权限；这些需要我们自己去设计 / 提供；然后通过相应的接口注入给 Shiro 即可。

####架构:

![](http://wiki.jikexueyuan.com/project/shiro/images/2.png)

- Subject : 主体,一个抽象概念；所有 Subject 都绑定到 SecurityManager，与 Subject 的所有交互都会委托给 SecurityManager；可以把 Subject 认为是一个门面；SecurityManager 才是实际的执行者；

- SecurityManager: 所有与安全有关的操作都会与 SecurityManager 交互；且它管理着所有 Subject；

- Realm：域，Shiro 从从 Realm 获取安全数据（如用户、角色、权限），就是说 SecurityManager 要验证用户身份，那么它需要从 Realm 获取相应的用户进行比较以确定用户身份是否合法；也需要从 Realm 得到用户相应的角色 / 权限进行验证用户是否能进行操作；可以把 Realm 看成 DataSource，即安全数据源。

####流程:

- 应用代码通过 Subject 来进行认证和授权，而 Subject 又委托给 SecurityManager；

- 我们需要给 Shiro 的 SecurityManager 注入 Realm，从而让 SecurityManager 能得到合法的用户及其权限进行判断。














