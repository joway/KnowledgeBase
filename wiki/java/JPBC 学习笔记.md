# JPBC 学习笔记

质数双线性群可以由五元组(p,G1,G2,GT,e)来描述
p是一个与给定安全常数λ相关的大质数
G1,G2,GT均是阶为p的乘法循环群
e为双线性映射e:G1×G2→GT

> 双线性（Bilinearity）：
> 1. 对于任意的g∈G1，h∈G2，a,b∈Zp，有e(ga,hb)=e(g,h)ab； 
> 2. 非退化性（Non-degeneracy）：至少存在元素g1∈G1,g2∈G2，满足e(g1,g2)≠1； 
> 3. 可计算性（Efficiency）：对于任意的u∈G1,v∈G2，存在一个与给定安全常数λ相关的多项式时间算法，可以高效地计算e(u,v)；

现在的密码学相关论文中，习惯将G1,G2设置为乘法循环群。但是，基于椭圆曲线的双线性群构造中，G1,G2是加法群。

jPBC中将G1,G2表示成了乘法循环群，因此在实现写成加法群形式的方案时，要注意将加法群改成乘法群的写法再进行实现。如何修改呢？很简单，把加法群中的加法运算写成乘法运算、把加法群中的乘法运算写成幂指数运算即可。

在jPBC中，双线性群的使用都是通过叫做Pairing的对象来实现的。

在密码学中，如果G1=G2，我们称这个双线性群是对称双线性群（Symmetric Bilinear Group），否则称之为非对称双线性群（Asymmetric Bilinear Group）。

Type:

A:对称质数阶双线性群

A1:数阶对称双线性群





使用注意:

1. Java的运算结果都是产生一个新的Element来存储，所以我们需要把运算结果赋值给一个新的Element；
2. Java在进行相关运算时，参与运算的Element值可能会改变。所以，如果需要在运算过程中保留参与运算的Element值，
   在存储的时候一定要调用getImmutable()，具体方法见代码中的初始化相关参数部分。
3. 为了保险起见，防止Element在运算的过程中修改了Element原本的数值，可以使用Element.duplicate()方法。
   这个方法将返回一个与Element数值完全一样的Element，但是是个新的Element对象。
   举例来说，如果做G1×G1[Math Processing Error]的运算，可以写成：
       Element G_1_m_G_1 = G_1.duplicate().mul(G_1_p.duplicate());
