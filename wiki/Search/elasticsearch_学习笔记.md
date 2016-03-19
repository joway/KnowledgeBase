## Elasticsearch 学习笔记

介绍
---

Elasticsearch也使用Java开发并使用Lucene作为其核心来实现所有索引和搜索的功能，但是它的目的是通过简单的RESTful API来隐藏Lucene的复杂性，从而让全文搜索变得简单。

特点:

- 分布式的实时文件存储，每个字段都被索引并可被搜索
- 分布式的实时分析搜索引擎
- 可以扩展到上百台服务器，处理PB级结构化或非结构化数据

Elasticsearch是面向文档(document oriented)的，这意味着它可以存储整个对象或文档(document)。然而它不仅仅是存储，还会索引(index)每个文档的内容使之可以被搜索。


在Elasticsearch中，文档归属于一种类型(type),而这些类型存在于索引(index)中. 类比传统关系型数据库


	Relational DB -> Databases -> Tables -> Rows -> Columns
	Elasticsearch -> Indices   -> Types  -> Documents -> Fields
	
	
	
数据
---

####文档

一个文档不只有数据。它还包含了元数据(metadata)——关于文档的信息。三个必须的元数据节点是：+

节点 |	说明
---|---
_index|文档存储的地方
_type|文档代表的对象的类
_id|文档的唯一标识

Nodes:

_id 仅仅只是一个字符串, 可自己定义, 不一定要是数据, 比如可以是一个url的哈希值(参见我的搜索引擎实现) . 当然, 如果不指定id值, ES会自动给我们默认生成一个22个字符长的 _id 值 (URL-safe, Base64-encoded string universally unique identifiers 即 UUIDs).




索引
---

- 索引（名词）:  一个索引(index)就像是传统关系数据库中的数据库，它是相关文档存储的地方，index的复数是indices 或indexes。
- 索引（动词）:  「索引一个文档」表示把一个文档存储到索引（名词）里，以便它可以被检索或者查询。这很像SQL中的INSERT关键字，差别是，如果文档已经存在，新的文档将覆盖旧的文档。
- 倒排索引 传统数据库为特定列增加一个索引，例如B-Tree索引来加速检索。Elasticsearch和Lucene使用一种叫做倒排索引(inverted index)的数据结构来达到相同目的。默认情况下，文档中的所有字段都会被索引（拥有一个倒排索引），只有这样他们才是可被搜索的。


文档唯一标识由四个元数据字段组成：

- _id：文档的字符串 ID
- _type：文档的类型名
- _index：文档所在的索引
- _uid：_type 和 _id 连接成的 type#id

默认情况下，_uid 是被保存（可取回）和索引（可搜索）的。_type 字段被索引但是没有保存，_id 和 _index 字段则既没有索引也没有储存，它们并不是真实存在的。



搜索
---





映射和分析
---

Elasticsearch为对字段类型进行猜测，动态生成了字段和类型的映射关系。

确切值(exact values)(比如string类型)及全文文本(full text)的区分是搜索引擎和其他数据库的根本差异.

####确切值(Exact values)

确切值是确定的,确切值"Foo"和"foo"就并不相同。确切值2014和2014-09-15也不相同。

确切值是很容易查询的.



####全文文本(Full text)

对于全文数据的查询来说，我们会询问这篇文档和查询的匹配程度如何.

我们还期望搜索引擎能理解我们的意图：

- 一个针对"UK"的查询将返回涉及"United Kingdom"的文档
- 一个针对"jump"的查询同时能够匹配"jumped"， "jumps"， "jumping"甚至"leap"
- "johnny walker"也能匹配"Johnnie Walker"， "johnnie depp"及"Johnny Depp"
- "fox news hunting"能返回有关hunting on Fox News的故事，而"fox hunting news"也能返回关于fox hunting的新闻故事。

为了对文本进行检索, Elasticsearch首先对文本分析(analyzes)，然后使用结果建立一个倒排索引。

### 倒排索引

Elasticsearch使用一种叫做倒排索引(inverted index)的结构来做快速的全文搜索。倒排索引由在文档中出现的唯一的单词列表，以及对于每个单词在文档中的位置组成。

两个文档，每个文档content字段包含：

1. The quick brown fox jumped over the lazy dog
2. Quick brown foxes leap over lazy dogs in summer

首先切分每个文档的content字段为单独的单词（我们把它们叫做词(terms)或者表征(tokens)）

把所有的唯一词放入列表并排序,如图 . 

![image](https://dn-joway.qbox.me/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-01-17%2014.49.32.png)

如果我们想搜索"quick brown"，我们只需要找到每个词在哪个文档中出现即可：

![image](https://dn-joway.qbox.me/屏幕快照 2016-01-17 14.52.32.png)

上面方法仍旧存在的问题:

1. "Quick"和"quick"被认为是不同的单词，但是用户可能认为它们是相同的。
2. "fox"和"foxes"很相似，就像"dog"和"dogs"——它们都是同根词。
3. "jumped"和"leap"不是同根词，但意思相似——它们是同义词。

解决方案:

1. "Quick"可以转为小写成为"quick"。
2. "foxes"可以被转为根形式"fox"。同理"dogs"可以被转为"dog"。
3. "jumped"和"leap"同义就可以只索引为单个词"jump"

这个表征化和标准化的过程叫做**分词**(analysis)

#### 分析和分析器

分析(analysis)过程：

1. 首先，表征化一个文本块为适用于倒排索引单独的词(term)
2. 然后标准化这些词为标准形式，提高它们的“可搜索性”或“查全率”

这个工作是分析器(analyzer)完成的。一个分析器(analyzer)只是一个包装用于将三个功能放到一个包里:

#####字符过滤器
	
首先字符串经过字符过滤器(character filter)，它们的工作是在表征化（译者注：这个词叫做断词更合适）前处理字符串。字符过滤器能够去除HTML标记，或者转换"&"为"and"。

#####分词器

分词器(tokenizer)被表征化（断词）为独立的词。一个简单的分词器(tokenizer)可以根据空格或逗号将单词分开（译者注：这个在中文中不适用）。

表征过滤

每个词都通过所有表征过滤(token filters)，它可以修改词（例如将"Quick"转为小写），去掉词（例如停用词像"a"、"and"``"the"等等），或者增加词（例如同义词像"jump"和"leap"）

#####分析器:

当我们索引(index)一个文档，全文字段会被分析为单独的词来创建倒排索引。不过，当我们在全文字段搜索(search)时，我们要让查询字符串经过同样的分析流程处理，以确保这些词在索引中存在。

系统内置了很多分析器.

当Elasticsearch在你的文档中探测到一个新的字符串字段，它将自动设置它为全文string字段并用standard分析器分析。+

为了指定分析器必须通过映射(mapping)人工设置这些字段。

###映射:

索引中每个文档都有一个类型(type)。 每个类型拥有自己的映射(mapping)或者模式定义(schema definition)。一个映射定义了字段类型，每个字段的数据类型，以及字段被Elasticsearch处理的方式。映射还用于设置关联到类型上的元数据。

![image](https://dn-joway.qbox.me/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-01-17%2015.17.45.png)

例如: 类型tweet的字段映射(属性(properties))为:

    {
       "gb": {
          "mappings": {
             "tweet": {
                "properties": {
                   "date": {
                      "type": "date",
                      "format": "dateOptionalTime"
                   },
                   "name": {
                      "type": "string"
                   },
                   "tweet": {
                      "type": "string"
                   },
                   "user_id": {
                      "type": "long"
                   }
                }
             }
          }
     	

    }

这些映射是Elasticsearch在创建索引时动态生成的.

#####自定义字段映射

######index

index参数控制字符串以何种方式被索引。它包含以下三个值当中的一个：+

值 |	解释
---|---
analyzed|	首先分析这个字符串，然后索引。换言之，以全文形式索引此字段。
not_analyzed|	索引这个字段，使之可以被搜索，但是索引内容和指定值一样。不分析此字段。
no|	不索引这个字段。这个字段不能为搜索到。


比如:

    {
        "tag": {
            "type":     "string",
            "index":    "not_analyzed"
        }
    }


**注意: 只有string 类型的值可以被index!**

对于analyzed类型的字符串字段，使用analyzer参数来指定哪一种分析器将在搜索和索引的时候使用。默认的，Elasticsearch使用standard分析器，但是你可以通过指定一个内建的分析器来更改它，例如whitespace、simple或english。(中文搜索分析器: ik_max_word)

    {
        "tweet": {
            "type":     "string",
            "analyzer": "english"
        }
    }
    
ik 分词工具的使用:

例如: 创建一个fulltext类型, 在属性表中, 做出如下映射:

{
    "fulltext": {
             "_all": {
            "analyzer": "ik_max_word",
            "search_analyzer": "ik_max_word",
            "term_vector": "no",
            "store": "false"
        },
        "properties": {
            "content": {
                "type": "string",
                "store": "no",
                "term_vector": "with_positions_offsets",
                "analyzer": "ik_max_word",
                "search_analyzer": "ik_max_word",
                "include_in_all": "true",
                "boost": 8
            }
        }
    }
}
    
#####更新映射

你可以向已有映射中增加字段，但你不能修改它。如果一个字段在映射中已经存在，这可能意味着那个字段的数据已经被索引。如果你改变了字段映射，那已经被索引的数据将错误并且不能被正确的搜索到。









