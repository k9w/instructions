# Introduction

# Install on OpenBSD

Install pip, a package manager for Python.

```
# pkg_add py3-pip
```

Use pip to install mkdocs.

```
$ pip install mkdocs                                                                                                                                    21:37:35 [30/155]
Defaulting to user installation because normal site-packages is not writeable                                                                                             
Collecting mkdocs                                                                                                                                                         
  Obtaining dependency information for mkdocs from https://files.pythonhosted.org/packages/89/58/aa3301b23966a71d7f8e55233f467b3cec94a651434e9cd9053811342539/mkdocs-1.5.3
-py3-none-any.whl.metadata                                                           
  Downloading mkdocs-1.5.3-py3-none-any.whl.metadata (6.2 kB)
Requirement already satisfied: click>=7.0 in /usr/local/lib/python3.10/site-packages (from mkdocs) (8.0.4)                                                                
Collecting ghp-import>=1.0 (from mkdocs)                                             
  Downloading ghp_import-2.1.0-py3-none-any.whl (11 kB)                        
Collecting jinja2>=2.11.1 (from mkdocs)                                              
  Obtaining dependency information for jinja2>=2.11.1 from https://files.pythonhosted.org/packages/30/6d/6de6be2d02603ab56e72997708809e8a5b0fbfee080735109b40a3564843/Jinj
a2-3.1.3-py3-none-any.whl.metadata                                                   
  Downloading Jinja2-3.1.3-py3-none-any.whl.metadata (3.3 kB)
Collecting markdown>=3.2.1 (from mkdocs)                                                                                                                                  
  Obtaining dependency information for markdown>=3.2.1 from https://files.pythonhosted.org/packages/42/f4/f0031854de10a0bc7821ef9fca0b92ca0d7aa6fbfbf504c5473ba825e49c/Mar
kdown-3.5.2-py3-none-any.whl.metadata                                                                                                                                     
  Downloading Markdown-3.5.2-py3-none-any.whl.metadata (7.0 kB)
Collecting markupsafe>=2.0.1 (from mkdocs)                                                                                                                                
  Downloading MarkupSafe-2.1.3.tar.gz (19 kB)                                                                                                                             
  Installing build dependencies ... done
  Getting requirements to build wheel ... done                                                                                                                            
  Preparing metadata (pyproject.toml) ... done                                                                                                                            
Collecting mergedeep>=1.3.4 (from mkdocs)                                                                                                                                 
  Downloading mergedeep-1.3.4-py3-none-any.whl (6.4 kB)                                                                                                                   
Requirement already satisfied: packaging>=20.5 in /usr/local/lib/python3.10/site-packages (from mkdocs) (23.1)     
Collecting pathspec>=0.11.1 (from mkdocs)                                                                                                                                 
  Obtaining dependency information for pathspec>=0.11.1 from https://files.pythonhosted.org/packages/cc/20/ff623b09d963f88bfde16306a54e12ee5ea43e9b597108672ff3a408aad6/pa
thspec-0.12.1-py3-none-any.whl.metadata                                                                                                                                   
  Downloading pathspec-0.12.1-py3-none-any.whl.metadata (21 kB)                                                                                                           
Collecting platformdirs>=2.2.0 (from mkdocs)                                                                                                                              
  Obtaining dependency information for platformdirs>=2.2.0 from https://files.pythonhosted.org/packages/be/53/42fe5eab4a09d251a76d0043e018172db324a23fcdac70f77a551c11f618
/platformdirs-4.1.0-py3-none-any.whl.metadata                                        
  Downloading platformdirs-4.1.0-py3-none-any.whl.metadata (11 kB)
Collecting pyyaml-env-tag>=0.1 (from mkdocs)
  Downloading pyyaml_env_tag-0.1-py3-none-any.whl (3.9 kB)
Requirement already satisfied: pyyaml>=5.1 in /usr/local/lib/python3.10/site-packages (from mkdocs) (5.4.1)
Collecting watchdog>=2.0 (from mkdocs)
  Downloading watchdog-3.0.0.tar.gz (124 kB)
     ──────────────────────────────────────── 124.6/124.6 kB 538.0 kB/s eta 0:00:00
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
  Preparing metadata (pyproject.toml) ... done
Requirement already satisfied: python-dateutil>=2.8.1 in /usr/local/lib/python3.10/site-packages (from ghp-import>=1.0->mkdocs) (2.8.2)
Requirement already satisfied: six>=1.5 in /usr/local/lib/python3.10/site-packages (from python-dateutil>=2.8.1->ghp-import>=1.0->mkdocs) (1.16.0)
Downloading mkdocs-1.5.3-py3-none-any.whl (3.7 MB)
   ──────────────────────────────────────── 3.7/3.7 MB 1.0 MB/s eta 0:00:00
Downloading Jinja2-3.1.3-py3-none-any.whl (133 kB)
   ──────────────────────────────────────── 133.2/133.2 kB 1.8 MB/s eta 0:00:00
Downloading Markdown-3.5.2-py3-none-any.whl (103 kB)
   ──────────────────────────────────────── 103.9/103.9 kB 1.4 MB/s eta 0:00:00
Downloading pathspec-0.12.1-py3-none-any.whl (31 kB)
Downloading platformdirs-4.1.0-py3-none-any.whl (17 kB)
Building wheels for collected packages: markupsafe, watchdog
  Building wheel for markupsafe (pyproject.toml) ... done
  Created wheel for markupsafe: filename=MarkupSafe-2.1.3-cp310-cp310-openbsd_7_4_amd64.whl size=21494 sha256=4aad6c4201061bd7a37d44e4022e560659fb09dd908a6665e0b213245882
575d                                      
  Stored in directory: ~/.cache/pip/wheels/08/b7/52/ab3fe954ddd34918c034054a37844e2e41682466078cec98e8
  Building wheel for watchdog (pyproject.toml) ... done
  Created wheel for watchdog: filename=watchdog-3.0.0-py3-none-any.whl size=82033 sha256=9149d5f83d1a7c36c05d1196aa33a61124e91b67d6650ea513ed0948b530f123
  Stored in directory: ~/.cache/pip/wheels/b8/93/8a/150c2a3417342f49d9e24948f65d2b0f3bce50b8a522d80128
Successfully built markupsafe watchdog
Installing collected packages: watchdog, pyyaml-env-tag, platformdirs, pathspec, mergedeep, markupsafe, markdown, jinja2, ghp-import, mkdocs
  WARNING: The script watchmedo is installed in '~/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
  WARNING: The script markdown_py is installed in '~/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
  WARNING: The script ghp-import is installed in '~/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
  WARNING: The script mkdocs is installed in '~/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed ghp-import-2.1.0 jinja2-3.1.3 markdown-3.5.2 markupsafe-2.1.3 mergedeep-1.3.4 mkdocs-1.5.3 pathspec-0.12.1 platformdirs-4.1.0 pyyaml-env-tag-0.1 wa
tchdog-3.0.0
```

Add ~/.local/bin to $PATH in ~/.profile. Log out and back in, or
restart your terminal window or tmux session.

pip does not include manapages for itself or any of its packages by
default. To get manapages, install click-man (suggested by
mkdocs.org). 

```
$ pip install click-man
```

Generate manpages for pip, click-man itself, and mkdocs. On OpenBSD,
these third-party manpages for regular utilities normally live at
/usr/local/man/man1. 

```
$ click-man --target /usr/local/man/man1 {pip,click-man,mkdocs}
```

But for me, click-man did not work at all.

```
$ click-man --help                                                                                                                                                      
Traceback (most recent call last):
  File "~/.local/bin/click-man", line 5, in <module>
    from click_man.__main__ import cli
  File "~/.local/lib/python3.10/site-packages/click_man/__main__.py", line 14, in <module>
    from pkg_resources import iter_entry_points, get_distribution
ModuleNotFoundError: No module named 'pkg_resources'
o$ click-man --target /usr/local/man/man1 {pip,click-man,mkdocs}
Traceback (most recent call last):
  File "~/.local/bin/click-man", line 5, in <module>
    from click_man.__main__ import cli
  File "~/.local/lib/python3.10/site-packages/click_man/__main__.py", line 14, in <module>
    from pkg_resources import iter_entry_points, get_distribution
ModuleNotFoundError: No module named 'pkg_resources'
```


