# Goge 搜索引擎设计文档


搜索结果模型:

SearchResultUnit:

     String title; 
     String url;
     String source; // 来源
     String digest; // max 140 letter 摘要
     Date date;
     double score;  // 评分( ElasticSearch 提供) 默认为0
     
     
ES 数据库设计:

Indices(_index) | Types(_type) | Documents(_id) | Fields(存储对象)
------|------|------|------|
'article' | source | hash( url ) | SearchResultUnit


Nodes:

针对每个不同来源(source), 都建立一个 Type , 并以其url的hash值(大写)为其 **_id**

设计思想: 把每个网站当作一个类, 该网站下的任何一条url作为该类生成的一个对象. 从url的书写格式上看, 也符合该思想. 

例如:  

对于 [https://goge.me/index.html](https://goge.me/index.html) 这个链接, 分析得到_type = goge.me, _id = hash(https://goge.me/index.html) , 爬取内容后, 将内容生成SearchResultUnit 对象存入对应field . 

---

# Goge 项目开发札记

####ToDo:

1. 对于 hibernate 的session何时关闭和开启无法把握, 以及多个查询合并成一个也无法把握 . 暂时用了getCurentSession() 的方法.
2. Shiro 的权限控制暂时还没弄好, 以及是否可以在每个Controller获知当前是哪个用户在访问暂时还不知道.
3. 日志系统(重要持久化至数据库, 边缘日志持久化至文件)未集成
4. 爬虫实时日志显示未完成
5. 全局统计分析(可从日志系统中获得)
6. 用户可自己在web界面手动输入规范化语句, 来测试是否能被爬虫爬取到需要的信息, 然后提交站点, 经国管理员审核后, 可纳入爬虫集群
7. 用户可看到自己的搜索信息报表
8. 用户可以自己爬取内容, 然后以自己的帐号来post至goge接口, 提交自己爬取的数据, 从而定制出自己的搜索引擎



#### 遇到的问题以及解决:

1. elasticsearch 的 Java SDK 中 , 最好用的是 Jest , 但是Jest的文档很少, 自己重新包装了一个Jest . 需要自己定义参数的时候, 可使用: setParameter() 和  的方法. 不过注意, elasticsearch 的 分页查询的 form 参数 在 jest 里 似乎被忘记了, 没有添加上, 可以手动添加, 这个只是一个常量而已. 

		.setParameter("from", (pageNum - 1) * Config.PAGING_SIZE) 
		
2. elasticsearch 分页查询里, form 参数 指定的是第几条记录, 而非第几页
3. 针对实时显示爬虫日志的需求, 简单点可以才用ajax轮询的方式, 定时请求数据, 不过 html5 中有一个websocket的机制, 可以实现 . Spring 4 支持 wesocket , 故才用这个技术以及socketjs这个javascript库实现了这个功能. 
4. websocket 日志实时显示功能遇到瓶颈, 我扩展了log4j的appender, 但是由于log4j里我没办法针对不同爬虫进行分类记录日志. (在网上找了, log4j很难针对性去分类日志, 只能在后期对日志进行分析)

		解决方案: 对于日志使用 #spiderId :[1]# 这种格式化的方式, 来进行日志分类. 
5. 为了让实时显示与爬虫启动彻底连接起来, 这里我才用了在websocket里进行爬虫的创建工作. 
6. 在分类系统爬虫和测试爬虫的时候, 由于websocket 最初 只能send一个字符串, 所以我这里那这个字符串作为spiderId , 但是由于我本来想测试爬虫就不用在数据库中, 但是这样就会在websocket里创建爬虫的时候找不到用户对爬虫的相关设置了. 但是放在数据库里的话, 这些测试爬虫都是用过一次就不用了, 会让浪费数据库空间. 所以, 我现在考虑的设计是, spiderId = 1 为主爬虫, 它的设置都存放在数据库中, 且作为系统爬虫在真实运行. 我需要设计出一种算法, 使得针对一个大数spiderId xxxxxx , 我可以从其中得到它是哪个主爬虫的测试爬虫. 最后发现由于一个主爬虫可能有多个测试爬虫, 这个算法设计会很麻烦, 所以才用在send() 阶段发送两个id , 一个spiderId , 一个测试爬虫的testId .

		conn.send("spiderId=${spider.id}#testId=${randNum}");

7. 在实现爬虫的监控的时候, 发现webmagic 自带的 JMX 似乎不支持以Java代码形式调用的方法(或许是我方法没用对, 但是关于这个网上的资料的确太少了) . 试了很多都没有用, 后来在网上找到一个demo , 按照demo里的方法, 需要修改webmagic里的代码才能用 . 于是我只好把代码拷贝下来本地编译使用库. 

	修改了monitor/SpiderMonitor.java 文件


	PS : 关于JMX还不是特别清楚, 修改过的代码也不知道会不会对其它部分产生bug,  等后期弄明白了以后可以考虑push到源库中. 
	
	不过还遇到一个问题, 一个 java 实例就会占用一个端口, 这个不知道怎么解决. 




















