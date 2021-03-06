package com.season.seasonStudy.thread;

public class VolatileTestB {

    public static volatile int race = 0;

    public static void increase() {
        race++;
    }

    private static final int THREADS_COUNT = 20;

    public static void main(String[] args) {
//        while (true) {
            race = 0;
            Thread[] threads = new Thread[THREADS_COUNT];
            for (int i = 0; i < THREADS_COUNT; i++){
                threads[i] = new Thread(()->{
                    for (int j = 0; j < 10_000; j++) {
                        synchronized (VolatileTestB.class){
                            increase();
                        }
                    }
                });
                threads[i].start();
            }
            while (Thread.activeCount() > 2){
                System.out.println(Thread.activeCount());
                Thread.yield();
            }
            System.out.println("------------");
                System.out.println(Thread.activeCount());
            System.out.println(race);
//        }
    }

}
