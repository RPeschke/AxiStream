mkdir build/coregen
mkdir build/coregen/ipcore

#cp -rf  ipcore/* build/coregen/ipcore/

python protoBuild/makeise/makeise.py  protoBuild/AxiStreamTest_Project.in build/axiTest.xise


python protoBuild/pyMakeScript.py