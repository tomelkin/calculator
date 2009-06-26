# Calculator #
## Calculator ## 
Simple macro to allow users to write basic arithmetic expressions comprised of MQL statements.

Once installed the calculator macro can be used like follows:

<pre><code>
{{
  calculator
    equation: a * (b + 3) % 5
    terms:
      - term: a
        mql: select COUNT(*) where 'type' = 'iteration'
      - term: b
        mql: select MAX('planning estimate') where type = story

}}
</code></pre>

* Supported arithmetic operators: + - * / % ( )
* Any valid symbol name in Ruby can be used for a term identifier.  Any number of terms can be used in an equation.
* At the moment equation terms can only resolve to MQL statements.
* If an MQL statement doesn't evaulate to a singular numeric value then an exception will be raised.  e.g. if a result set of size > 1, or if the result is a string.
