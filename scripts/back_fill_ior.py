#/bin/bash 
import re
import time,datetime
import os,sys
old_ior='/project/projectdirs/mpccc/fbench/IOR_CSCRATCH/IOR_HSW'

xdir_dir=[ os.path.join(old_ior,name) for name in os.listdir(old_ior) if os.path.isdir(os.path.join(old_ior, name)) ]

def construct_sql(fileior):
    file=open(fileior,'r')
    row = file.readlines()
    dateior_unix=[]
    ior_write=0
    ior_read=0
    for line in row:
        if re.search("Began",line):
            temdateior=line.replace('Began: ',"")
            temdateior=temdateior.replace('\n',"")
#            print temdateior
            dateior_unix.append(int(time.mktime(datetime.datetime.strptime(temdateior, "%c").timetuple())))
#            print dateior_unix
        if re.search('Max Write',line):
            ior_write=(line.split(' ')[2])
#            print ior_write
        if re.search('clients',line):
            numtasks=line.replace(' ',"").split('=')[-1].split('(')[0]
        if re.search('Max Read', line):
            ior_read=(line.split(' ')[3])
#            print ior_read
            break
    bench_name_write=fileior.split('/')[7]+'_write'
    bench_name_read=fileior.split('/')[7]+'_read'
    jobid=fileior.split('_')[-1].split('.')[0]
    hostname='cori'
    cmd=[]
    if len(dateior_unix)==2:
     cmd.append('python report-ior.py insert %s %s %s %s %s %s'%(bench_name_write, dateior_unix[0], jobid, numtasks, hostname, ior_write))
     cmd.append('python report-ior.py insert %s %s %s %s %s %s'%(bench_name_read, dateior_unix[1], jobid, numtasks, hostname, ior_read))
     print cmd[0]
     print cmd[1]
    return cmd

i=7
ior_test=[ os.path.join(xdir_dir[i],name) for name in os.listdir(xdir_dir[i]) if name.endswith('IOR') and '_1000000_' in name]
#ior_test=[ os.path.join(xdir_dir[i],name) for name in os.listdir(xdir_dir[i]) if name.endswith('IOR')]
print 'now processing %s '%(xdir_dir[i])

tt=time.time()
for i in range(len(ior_test)):
 cmd=construct_sql(ior_test[i])
 if len(cmd)==2:
  os.system(cmd[0])
  os.system(cmd[1])
ttend=time.time()
print 'insert %d records takes %.2f second'%(len(ior_test),ttend-tt)
