#!/bin/bash
export JAVA_OPTS="-verbose:gc -XX:+UseParallelOldGC -XX:+PrintCommandLineFlags"
nohup rake oa:top_tweeters[$1] &
