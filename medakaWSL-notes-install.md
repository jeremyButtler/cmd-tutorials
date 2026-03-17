Done on Ubuntu

# Install medaka by python

This works on Ubuntu or Mac.

```
python3 -m venv ~/Downloads/pipMedaka;
. ~/Downloads/pipMedaka/bin/venv/activate;
pip install --upgrade pip;
pip install medaka;
```

# Install medaka from source

I could not do this on a Mac because the Mac python was
  out of date.

Dependencies I installed. I was unable to install
  the python-virtualenv package. It looks like Debian
  and Ubunut do python-evn.

```
sudo apt-get install \
   bzip2 g++ zlib1g-dev libbz2-dev liblzma-dev \
   libffi-dev libncurses-dev libcurl4-gnutls-dev \
   libssl-dev curl make cmake wget python3-all-dev \
   python-venv;
sudo apt-get install git-lfs;
git-lfs install;
```

```
cd ~/Downloads;
git clone https://github.com/nanoporetech/medaka medaka;
cd medaka;
git-lfs fetch;
git-lfs checkout;
make install;
```

```
. ~/Downloads/medaka/vevn/bin/activate;
```

Quit shell with `deactivate`.


