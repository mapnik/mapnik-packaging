# script to build boost python versions
# this should be run with the boost source directory as the cwd

import os
import sys

USER_JAM = """
import option ;
import feature ;
project : default-build <toolset>%(toolset)s ;
using python
     : %(ver)s # version
     : %(system)s%(platform_root)s%(ver)s/bin/python%(ver)s%(variant)s # cmd-or-prefix
     : %(system)s%(platform_root)s%(ver)s/include/python%(ver)s%(variant)s # includes
     : %(system)s%(platform_root)s%(ver)s/lib/python%(ver)s/config%(variant)s # a lib actually symlink
     : <toolset>%(toolset)s # condition
     ;
libraries = --with-python ;
"""

# arch: ='32_64'

# TODO - figure out linux
OSX_PLATFORM_ROOT="/Library/Frameworks/Python.framework/Versions/"

def compile_lib(ver,toolset,addr_model,arch):
    if ver in ('3.2','3.3'):
        open('user-config.jam','w').write(USER_JAM % {'ver':ver,
           'system':'',
           'variant':'m',
           'toolset':toolset,
           'platform_root':OSX_PLATFORM_ROOT})
    elif ver in ('2.5','2.6','2.7'):
        # build against system pythons so we can reliably link against FAT binaries
        open('user-config.jam','w').write(USER_JAM % {'ver':ver,
            'system':'/System',
            'variant':'',
            'toolset':toolset,
            'platform_root':OSX_PLATFORM_ROOT})
    else:
        # for 2.7 and above hope that python.org provides 64 bit ready binaries...
        open('user-config.jam','w').write(USER_JAM % {'ver':ver,
            'system':'',
            'variant':'',
            'toolset':toolset})
    cmd = "./b2 -q --with-python -a -j6 --ignore-site-config --user-config=user-config.jam link=static toolset=%s -d2 address-model=%s architecture=%s variant=release stage" % (toolset,addr_model,arch)
    cmd += ' linkflags="%s"' % os.environ['LDFLAGS']
    cmd += ' cxxflags="%s"' % os.environ['CXXFLAGS']
    print cmd
    os.system(cmd)

if __name__ == '__main__':
    if not len(sys.argv) > 4:
        sys.exit('usage: %s <ver> <toolset> <addr_model> <arch>' % os.path.basename(sys.argv[0]))
    compile_lib(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
    
    