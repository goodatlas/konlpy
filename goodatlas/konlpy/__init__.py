from .version import __version__
__title__ = 'KoNLPy'
__author__ = 'Lucy Park'
__editor__ = 'Kcrong'
__license__ = 'GPL v3'
__copyright__ = 'Copyright 2015 Lucy Park'

try:
    from .downloader import download
except IOError:
    pass
from .jvm import init_jvm
from . import corpus
from . import data
from . import internals
from . import tag
