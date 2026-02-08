#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

const char *log_types[] = {"ERROR", "WARNING", "INFO", "CRITICAL", "FAILED"};
const char *services[] = {"httpd", "sshd", "mysql", "nginx", "postgres"};
const char *ips[] = {"192.168.1.", "10.0.0.", "172.16.0.", "203.0.113.", "198.51.100."};

void generate_log_line(FILE *fp) {
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    
    // Random date in January 2025
    int day = 10 + (rand() % 20);
    int hour = rand() % 24;
    int minute = rand() % 60;
    int second = rand() % 60;
    
    fprintf(fp, "2025-01-%02d %02d:%02d:%02d ", day, hour, minute, second);
    
    // 30% chance of error/warning
    if (rand() % 100 < 30) {
        const char *type = log_types[rand() % 5];
        const char *service = services[rand() % 5];
        int ip_last = rand() % 255;
        
        fprintf(fp, "%s: %s service issue at %s%d\n", 
                type, service, ips[rand() % 5], ip_last);
    } else {
        fprintf(fp, "INFO: Normal operation of %s\n", services[rand() % 5]);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <num_lines>\n", argv[0]);
        return 1;
    }
    
    int num_lines = atoi(argv[1]);
    if (num_lines <= 0) {
        fprintf(stderr, "Invalid number of lines\n");
        return 1;
    }
    
    srand(time(NULL));
    
    // Create test directory
    system("mkdir -p ../out/monitor/raw");
    
    // Generate system.log
    FILE *fp = fopen("../out/monitor/raw/system.log", "w");
    if (!fp) {
        perror("Error creating system.log");
        return 1;
    }
    for (int i = 0; i < num_lines; i++) {
        generate_log_line(fp);
    }
    fclose(fp);
    
    // Generate network.log
    fp = fopen("../out/monitor/raw/network.log", "w");
    if (!fp) {
        perror("Error creating network.log");
        return 1;
    }
    for (int i = 0; i < num_lines; i++) {
        generate_log_line(fp);
    }
    fclose(fp);
    
    // Generate security.log
    fp = fopen("../out/monitor/raw/security.log", "w");
    if (!fp) {
        perror("Error creating security.log");
        return 1;
    }
    for (int i = 0; i < num_lines; i++) {
        generate_log_line(fp);
    }
    fclose(fp);
    
    printf("Generated 3 log files with %d lines each\n", num_lines);
    return 0;
}
