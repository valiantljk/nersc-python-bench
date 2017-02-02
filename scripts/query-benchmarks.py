#!/usr/bin/env python

# module load python/2.7-anaconda
# python query-benchmarks.py

import  argparse
import  datetime
import  os
import  sys

import  MySQLdb
import  numpy as np
import  pandas as pd
import  pytz


pd.set_option("display.width", None)

TZ = pytz.timezone("America/Los_Angeles")

DATE_FORMAT = "%Y-%m-%d"
UNIX_EPOCH = datetime.datetime(1970, 1, 1)

MYSQL_DEFAULT_FILE_PATH = os.path.join(os.environ[ "HOME" ], ".mysql", ".my_staffdb01.cnf")

BENCHMARKS = ["mpi4py-import", "pynamic"]
MACHINES = ["cori-haswell", "edison"]
RESOURCES = ["common", "datawarp", "project", "scratch", "shifter"]
SIZES = ["small", "large"]


def main():
    args = parse_arguments()
    benchmark_names = form_benchmark_names(args)
    df = report_for_period_ending(benchmark_names, args.period, args.ending)
    print_report(df) # or whatever you like...


def print_report(df):
    if df.empty:
        return
    print
    benchmark_names = df.bench_name.unique()
    for name in benchmark_names:
        selection = df.loc[df["bench_name"] == name]
        if selection.empty:
            continue
        print name
        print "".join(["-" for i in range(len(name))])
        print selection[["timestamp", "metric_value"]]
        print


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--benchmark", "-b", 
            help = "benchmark name", 
            choices = BENCHMARKS)
    parser.add_argument("--machine", "-m",
            help = "machine name",
            choices = MACHINES)
    parser.add_argument("--resource", "-r",
            help = "storage or container resource",
            choices = RESOURCES)
    parser.add_argument("--size", "-s",
            help = "size of benchmark test",
            choices = SIZES)
    parser.add_argument("--period", "-p",
            help = "length of sampling period (days) [%(default)s]", 
            default = 60)
    parser.add_argument("--ending", "-e",
            help = "sampling period UTC end date YYYY-MM-DD [today]")
    return parser.parse_args()


def form_benchmark_names(args):
    benchmarks = BENCHMARKS if args.benchmark is None else [args.benchmark]
    machines = MACHINES if args.machine is None else [args.machine]
    resources = RESOURCES if args.resource is None else [args.resource]
    sizes = SIZES if args.size is None else [args.size]

    benchmark_names = list()
    for benchmark in benchmarks:
        for machine in machines:
            for resource in resources:
                for size in sizes:
                    try:
                        name = form_benchmark_name(benchmark, machine, resource, size)
                    except ValueError:
                        continue
                    benchmark_names.append(name)
    return benchmark_names


def form_benchmark_name(benchmark, machine, resource, size):
    assert_resource(machine, resource)
    nodes = size_to_nodes(machine, size)
    return "-".join([benchmark, machine, resource, nodes])


def assert_resource(machine, resource):
    if machine == "cori-haswell":
        return assert_resource_cori_haswell(resource)
    if machine == "edison":
        return assert_resource_edison(resource)
    raise ValueError


def assert_resource_cori_haswell(resource):
    pass


def assert_resource_edison(resource):
    if resource != "datawarp":
        pass        
    raise ValueError


def size_to_nodes(machine, size):
    if machine == "cori-haswell":
        return size_to_nodes_cori_haswell(size)
    if machine == "edison":
        return size_to_nodes_edison(size)
    raise ValueError


def size_to_nodes_cori_haswell(size):
    if size == "small":
        return "003"
    if size == "large":
        return "150"
    raise ValueError


def size_to_nodes_edison(size):
    if size == "small":
        return "004"
    if size == "large":
        return "200"
    raise ValueError


def report_for_period_ending(benchmark_names, period, ending):
    begin, end = period_ending_to_begin_end(period, ending)
    df = query_by_begin_end(benchmark_names, begin, end)
    df.timestamp = UNIX_EPOCH + pd.to_timedelta(df.timestamp, "s")
    df.timestamp = df.timestamp.dt.tz_localize(pytz.utc).dt.tz_convert(TZ)
    return df["timestamp bench_name numtasks hostname metric_value".split()].sort_values("timestamp")


def period_ending_to_begin_end(period, ending):
    ending = ending or datetime.datetime.utcnow().strftime(DATE_FORMAT)
    end = datetime.datetime.strptime(ending, DATE_FORMAT)
    begin = end - datetime.timedelta(days = period)
    end += datetime.timedelta(days = 1)
    return timestamp(begin), timestamp(end)


def timestamp(datetime):
    return (datetime - UNIX_EPOCH).total_seconds()


def query_by_begin_end(benchmark_names, begin, end):
    sql, params = sql_from_timestamp_range(benchmark_names, begin, end)
    return pd.read_sql(sql, broker_database_connection(), params = params)


def sql_from_timestamp_range(benchmark_names, begin, end):
    return ("""select 
        bench_name, 
        timestamp, 
        metric_value, 
        jobid, 
        numtasks, 
        hostname 
    from monitor
    where bench_name in %s
        and metric_value is not null
        and notes is null
        and timestamp between %s and %s""", 
        (benchmark_names, begin, end))


def broker_database_connection():
    return MySQLdb.connect(db = "benchmarks", read_default_file = MYSQL_DEFAULT_FILE_PATH)


if __name__ == "__main__":
    sys.exit(main())
