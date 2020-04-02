# Install Apache Spark on Windows

I heavily modified the code here but the majority of the code was made by [user:ornrocha on GitHub](https://github.com/ornrocha/apache-spark-on-windows).

This repository contains a powershell script to install Apache Spark on Windows 10 automatically.
The goal is to create an environment on a personal computer for developing and testing routines for processing large-scale data using Spark. 
However, spark will use only the number of cores of your pc, so you will not have the distributed computing capabilities presented in cloud systems like Microsoft Azure, AWS, etc...

I don't recommend using it for a production environment.

This script has been modified to allow for installation of what is needed for .NET for Apache® Spark™. For more details see [here](https://github.com/dotnet/spark)

## Programs that will be installed:

- for all options
    1. Java SDK 1.8
    1. Maven
    1. Hadoop Winutils 2.7.1
    1. Apache Spark with Hadoop 2.7
- If `y` answered for Scala option
    - Scala
- If `y` answered for dotnet option
    - dotnetcore-sdk

## How to install?

1. Download the script "spark-install.ps1".
1. Open Powershell (I used PowerShell 7 I haven't tested any others)
1. cd to the root folder where you downloaded the script.
1. Execute the following command:

    ```PowerShell
    powershell -executionpolicy bypass -File .\spark-install.ps1
    ```

1. Follow the instructions.

## How to test if apache spark works?

- Open a CMD shell and execute:

    ```PowerShell
    spark-shell
    ```

## Things I'd like to add

I would like to add back in the anaconda set up with a virtual environment but I usually do that elsewhere for each project so it might not happen

I'm not sure about this one but maybe adding a couple of examples may happen here as well
