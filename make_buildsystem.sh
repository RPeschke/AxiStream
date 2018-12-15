mkdir build/coregen
mkdir build/coregen/ipcore

#cp -rf  ipcore/* build/coregen/ipcore/

python protoBuild/makeise/makeise.py  protoBuild/AxiStreamTest_Project.in build/axiTest.xise

python protoBuild/makeise/makePrj.py protoBuild/AxiStreamTest_Project.in build/
python protoBuild/pyMakeScript.py