Flask踩坑记录
=======

1. url_for() 函数响应失败:
--------


	@main.route('/')
	def index():
	    print(User.query.all())
	    return redirect(url_for('footer'))
	
	@main.route('/footer')
	def footer():
	    return render_template('footer.html')

这么简单的一个函数在本来没有用蓝本的时候是可以跑的，用了蓝本后就会爆出：

	werkzeug.routing.BuildError
	werkzeug.routing.BuildError: ('footer', {}, None)

排查了好久，以为是数据库操作的时候会导致url_for()函数失效，但是后来发现，其实是url_for()函数直接在app中使用和在蓝本中使用行为是不一样的。

于是我开始排查url_for()的特性，通过关键词：url_for blueprints 找到一篇文章：[http://stackoverflow.com/questions/19261833/what-is-an-endpoint-in-flask](http://stackoverflow.com/questions/19261833/what-is-an-endpoint-in-flask)

我总结下这篇文章里的关键部分：

虽然之前我们用的url_for()都是用函数名来建立映射关系的，但是由于我们有了"蓝本"这个东西，所以我们可以把整个url路径给模块化，类似于分包的机制，但是如果是这样，那么假如我在lab蓝本和school蓝本下都要建立user()函数就会有重名的麻烦，所以我们就引入了namespaces。

其实这样也很容易理解，因为假如单单靠函数名，那么关系就会很乱，没有层次，而namespace的引入就有层次多了。

假如下面这样的：

**main.py:**

	from flask import Flask, Blueprint
	from admin import admin
	from user import user
	
	app = Flask(__name__)
	app.register_blueprint(admin, url_prefix='admin')
	app.register_blueprint(user, url_prefix='user')

**admin.py:**

	admin = Blueprint('admin', __name__)
	
	@admin.route('/greeting')
	def greeting():
	    return 'Hello, administrative user!'

**user.py:**

	user = Blueprint('user', __name__)
	@user.route('/greeting')
	def greeting():
	    return 'Hello, lowly normal user!'


注意，admin和user里的函数名都是greating

在用蓝本的时候，我们要调用url_for()的话，就要用：

	print url_for('admin.greeting') # Prints '/admin/greeting'
	print url_for('user.greeting') # Prints '/user/greeting'

PS：

后来我查看Flask的源代码的时候，发现两件事情：

1. url_for()的签名是：url_for(endpoint, **values)，在这里函数名本身就是endpoint
2. 函数注释有一段话：

> In case blueprints are active you can shortcut references to the same blueprint by prefixing the local endpoint with a dot (``.``).

> This will reference the index function local to the current blueprint::
> 
>url_for('.index')



------


另外，endpoint还有一个小问题就是：

	app = Flask(__name__)
	
	# We can use url_for('foo_view') for reverse-lookups in templates or view functions
	@app.route('/foo')
	def foo_view():
	    pass
	
	# We now specify the custom endpoint named 'bufar'. url_for('bar_view') will fail!
	@app.route('/bar', endpoint='bufar')
	def bar_view():
	    pass
	
	with app.test_request_context('/'):
	    print url_for('foo_view')
	    print url_for('bufar')
	    # url_for('bar_view') will raise werkzeug.routing.BuildError
	    print url_for('bar_view')


上面这段程序里，由于route()路由里添加了endpoint，所以其值就是url_for要调用的值，而其函数是不能够再调用了得！

这个的原因是因为假如endpoint不指定的话，默认为函数的名称，假如指定的话那么当然是指定值了