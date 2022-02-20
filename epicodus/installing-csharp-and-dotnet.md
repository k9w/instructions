<p>
# 02-20-2022

I had previously setup most of these tools, including for C#. But today
while going throught the C# pre-work, I found dotnet 6 from the Fedora
repos gives errors for the code samples in the lessons. I'll look to
switch to dotnet 5.

First remove the previously installed dotnet 6.

```
# dnf remove dotnet-script dotnet
```

Then follow the instructions for Dotnet SDK 5 at:
https://docs.microsoft.com/en-us/dotnet/core/install/linux-fedora#install-net-5

```
# dnf install dotnet-sdk-5.0
Last metadata expiration check: 3:46:10 ago on Sat 19 Feb 2022 10:30:09
AM PST.
Package dotnet-sdk-5.0-5.0.206-1.fc35.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
$ dotnet --version
5.0.206
```

The 'dnf remove' command removed every dependency for Dotnet 6. But the
'dnf install' command above shows dotnet-sdk-5.0 was already loaded on
my Fedora install.

Dotnet-script was also still installed. In learnhowtoprogram.com's test
instruction, calling the variable 'hello' just using the word 'hello'
didn't work.

```
$ dotnet-script
> string hello = "Hello world!";
> hello;
(1,1): error CS0201: Only assignment, call, increment, decrement, await,
and new object expressions can be used as a statement
>
Ctrl-C
$
```

This worked instead.
https://github.com/filipw/dotnet-script#usage

```
> Console.WriteLine(hello);
Hello world!
>
```
