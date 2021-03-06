import re


example_algebras = [
    { 
        'name':'count',
        'agg':'count(x)',
        'type':'INTEGER',
        'zero':'0',
        'plus':'count(x)+count(y)',
        'negate':'-x',
        'view':'x',
    },
    { 
        'name':'sum',
        'agg':'sum(x)',
        'type':'INTEGER',
        'zero':'0',
        'plus':'sum(x)+sum(y)',
        'negate':'-x',
        'view':'sum(x)',
    },
    { 
        'name':'hll_add_agg',
        'agg':'hll_add_agg(x)',
        'type':'hll',
        'zero':'hll_empty()',
        'plus':'hll_add_agg(x)||hll_add_agg(y)',
        'negate':None,
        'view':'x',
    },
    { 
        'name':'hll_count',
        'agg':'hll_add_agg(hll_hash_any(x))',
        'type':'hll',
        'zero':'hll_empty()',
        'plus':'hll_count(x)||hll_count(y)',
        'negate':None,
        'view':'round(hll_cardinality(hll_count(x)))',
    }
    ]


def substitute_views(text, algebras=example_algebras):
    '''
    >>> substitute_views('count(*)-sum(num)')
    'count(*)-sum(num)'
    >>> substitute_views('count(*)')
    'count(*)'
    >>> substitute_views('count(*)+count(*)+count(*)')
    'count(*)+count(*)+count(*)'
    >>> substitute_views('f(x)-count(*)')
    'f(x)-count(*)'
    >>> substitute_views('f(x) - sum(f(y))')
    'f(x) - sum(f(y))'
    >>> substitute_views('round(hll_cardinality(hll_add_agg(hll_hash_any(name))))')
    'round(hll_cardinality(hll_add_agg(hll_hash_any(name))))'
    >>> substitute_views('round(hll_cardinality(hll_add_agg(hll_hash_any(test.num))))')
    'round(hll_cardinality(hll_add_agg(hll_hash_any(test.num))))'
    '''
    for algebra in algebras:
        matches = re.finditer(r'([^"a-zA-Z_0-9]|^)('+algebra['name']+')\(', text)
        new_text = ''
        last_text_index = 0
        for match in matches:
            num_lparens = 0
            for i in range(match.start(2), len(text)):
                if text[i]=='(':
                    num_lparens+=1
                if text[i]==')':
                    num_lparens-=1
                    if num_lparens==0:
                        break
            expr = text[match.end(2)+1:i]
            if algebra['view'] != 'x':
                value = re.sub(r'\bx\b',expr,algebra['view'])
            else:
                value = text[match.start(2):i+1]
            new_text += text[last_text_index:match.start(2)]+value
            last_text_index = i+1
        new_text += text[last_text_index:]
        text = new_text
    return text


def extract_algebras(text, algebras=example_algebras):
    '''
    >>> extract_algebras('count(*)-sum(num)')[1]
    '"count(*)"-"sum(num)"'
    >>> extract_algebras('count(*)')[1]
    '"count(*)"'
    >>> extract_algebras('hll_count(*)')[1]
    '"hll_count(*)"'
    >>> extract_algebras('hll_count(*)')[1]
    '"hll_count(*)"'
    >>> extract_algebras('count(*)+count(*)+count(*)')[1]
    '"count(*)"+"count(*)"+"count(*)"'
    >>> extract_algebras('f(x)-count(*)')[1]
    'f(x)-"count(*)"'
    >>> extract_algebras('f(x) - sum(f(y))')[1]
    'f(x) - "sum(f(y))"'
    >>> extract_algebras('round(hll_cardinality(hll_add_agg(hll_hash_any(test.name))))')[1]
    'round(hll_cardinality("hll_add_agg(hll_hash_any(test.name))"))'
    >>> extract_algebras('round(hll_cardinality(hll_add_agg(hll_hash_any(test.name))))')[0]
    {'hll_add_agg(hll_hash_any(test.name))'}
    '''
    dependencies = set()
    for algebra in algebras:
        matches = re.finditer(r'([^"a-zA-Z_0-9]|^)('+algebra['name']+')\(', text)
        new_text = ''
        last_text_index = 0
        for match in matches:
            num_lparens = 0
            for i in range(match.start(2), len(text)):
                if text[i]=='(':
                    num_lparens+=1
                if text[i]==')':
                    num_lparens-=1
                    if num_lparens==0:
                        break
            value = text[match.start(2):i+1]
            expr = text[match.end(2)+1:i]
            new_text += text[last_text_index:match.start(2)]+'"'+algebra['name']+'('+expr+')"'
            last_text_index = i+1
            dependencies.add(value)
        new_text += text[last_text_index:]
        text = new_text
    return dependencies,text


def _algsub(text, x='', y=''):
    '''
    >>> _algsub('hll_add_agg(x)', 'test')
    'hll_add_agg(test)'
    >>> _algsub('x||y', 'left', 'right')
    'left||right'
    >>> _algsub('xy(x,y)', 'left', 'right')
    'xy(left,right)'
    '''
    return re.sub(r'\by\b',y,re.sub(r'\bx\b',x,text))
