# mrubyudf

これは mruby で MySQL のユーザー定義関数(UDF)を簡単に作成するためのツールです。

## インストール

```sh
% gem install mrubyudf
```

## 準備

mysql_config コマンドと MySQL のヘッダファイルが必要です。

mysql-8.4.2-linux-glibc2.28-x86_64.tar.xz みたいなファイルを展開した中には入ってるはずです。

それ以外の場合は MySQL 開発環境のインストールが必要になるかも知れません。
Ubuntu の場合は libmysqlclient-dev パッケージをインストールすればいいと思います。

## 使い方

まず mruby をインストールする必要があります。mruby を動的リンクにするため config を指定して make します。

```sh
% git clone git@github.com:mruby/mruby.git
% cd mruby
% MRUBY_CONFIG=$GEM_HOME/gems/mrubyudf-0.2.0/misc/shared.rb make
```

うまくいかない場合は頑張ってください。

この mruby ディレクトリを MRUBY_PATH 変数に設定しておきます。

```sh
% MRUBY_PATH=$(pwd)/bin
```

関数本体を作ります。ここではフィボナッチ数を返す fib() 関数を fib.rb ファイルとして作ります。

```ruby
FIXNUM_MAX = 2**62-1
def fib(n)
  a, b = 1, 0
  n.times { a, b = b, a + b }
  raise 'Overflow' if b > FIXNUM_MAX
  b
end
```

mruby で実行して動きを確かめます。

```sh
% $MRUBY_PATH/mruby -r ./fib.rb -e 'p fib(10)'
55
% $MRUBY_PATH/mruby -r ./fib.rb -e 'p fib(90)'
2880067194370816120
% $MRUBY_PATH/mruby -r ./fib.rb -e 'p fib(91)'
trace (most recent call last):
        [1] -e:1
./fib.rb:5:in fib: Overflow (RuntimeError)
```

関数名、戻り値の型、引数の型等の情報を fib.spec ファイルで次のような感じで作ります。

```ruby
MrubyUdf.function do |f|
  f.name = 'fib'           # 関数名は fib
  f.return_type = Integer  # 戻り値は Integer
  f.arguments = [          # 引数は一つで型は Integer
    Integer
  ]
end
```

コンパイル。

```sh
% PATH=$MRUBY_PATH:$PATH mrubyudf fib.spec
```

うまくいけば fib.so ファイルができます。

これを MySQL のプラグインディレクトリにコピーします。

```sh
% sudo cp fib.so $(mysql_config --plugindir)
```

MySQL に組み込みます。一度やっておけば mysqld を再起動しても自動的に組み込まれます。

```sql
% mysql -uroot
mysql> create function fib returns int soname 'fib.so';
```

使ってみます。

```sql
mysql> select fib(10);
+---------+
| fib(10) |
+---------+
|      55 |
+---------+
1 row in set (0.01 sec)

mysql> select fib(90);
+---------------------+
| fib(90)             |
+---------------------+
| 2880067194370816120 |
+---------------------+
1 row in set (0.01 sec)

mysql> select fib(91);
+---------+
| fib(91) |
+---------+
|    NULL |
+---------+
1 row in set (0.00 sec)
```

関数が要らなくなったら破棄します。

```sql
mysql> drop function fib;
```

drop しないで so ファイルを更新したりすると、mysqld が落ちるので注意。

example 配下にテキトーなサンプルがいくつかあります。


## ライセンス

このツール自体は GPL 3 です。

このツールによって作られた so ファイルは、このツールのライセンスとは無関係です。

## 作者

とみたまさひろ <https://twitter.com/tmtms>
