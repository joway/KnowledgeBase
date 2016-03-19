#OpenGL 学习笔记

PS: Xcode 7 目前已支持OpenGL 新版本了。

- The OpenGL Extension Wrangler (GLEW):
	访问OpenGL 3.2 API函数
- GLFW:
	跨平台创建窗口，接受鼠标键盘消息
- OpenGL Mathematics (GLM)：
	一个数学库，用来处理矢量和矩阵等几乎其它所有东西
	
## Shaders

运行在GPU上而非CPU.

使用OpenGL Shading Language (GLSL)语言编写，看上去像C或C++，但却是另外一种不同的语言。

用处: 着色

| |主程序|Shader程序|
|:---|:---|:---|
|语言|C++|GLSL|
|主函数|int main(int, char**);|void main();|
|运行于|CPU|GPU|
|需要编译？|是|是|
|需要链接？|是|是|

###Vertex shader

用来将点（x，y，z坐标）变换成不同的点.

顶点只是几何形状中的一个点，一个点叫vectex，多个点叫vertices














