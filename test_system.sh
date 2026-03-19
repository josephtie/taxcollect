#!/bin/bash

# Script de Test Automatisé - TaxCollect System
# Usage: ./test_system.sh [backend|frontend|all]

set -e

BACKEND_URL="http://localhost:8080"
FRONTEND_URL="http://localhost:3000"
LOG_FILE="test_results_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log "${BLUE}🧪 Démarrage des tests TaxCollect - $(date)${NC}"
log "Fichier de log: $LOG_FILE"

# Test Backend Health
test_backend_health() {
    log "${YELLOW}🏥 Test de santé du backend...${NC}"
    
    if curl -f -s "$BACKEND_URL/actuator/health" > /dev/null; then
        log "${GREEN}✅ Backend is healthy${NC}"
        return 0
    else
        log "${RED}❌ Backend is not responding${NC}"
        return 1
    fi
}

# Test Agent Controller
test_agent_controller() {
    log "${YELLOW}👤 Test Agent Controller...${NC}"
    
    # Test GET all
    if curl -f -s "$BACKEND_URL/api/taxcollect/agent/all" > /dev/null; then
        log "${GREEN}✅ GET /agent/all${NC}"
    else
        log "${RED}❌ GET /agent/all${NC}"
    fi
    
    # Test POST
    AGENT_DATA='{"nom":"Test","prenom":"Agent","email":"test@test.com","telephone":"123456789"}'
    AGENT_ID=$(curl -s -X POST "$BACKEND_URL/api/taxcollect/agent" \
        -H "Content-Type: application/json" \
        -d "$AGENT_DATA" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    
    if [ ! -z "$AGENT_ID" ]; then
        log "${GREEN}✅ POST /agent (ID: $AGENT_ID)${NC}"
        
        # Test PUT
        if curl -f -s -X PUT "$BACKEND_URL/api/taxcollect/agent/$AGENT_ID" \
            -H "Content-Type: application/json" \
            -d '{"nom":"Updated"}' > /dev/null; then
            log "${GREEN}✅ PUT /agent/$AGENT_ID${NC}"
        else
            log "${RED}❌ PUT /agent/$AGENT_ID${NC}"
        fi
        
        # Test DELETE
        if curl -f -s -X DELETE "$BACKEND_URL/api/taxcollect/agent/$AGENT_ID" > /dev/null; then
            log "${GREEN}✅ DELETE /agent/$AGENT_ID${NC}"
        else
            log "${RED}❌ DELETE /agent/$AGENT_ID${NC}"
        fi
    else
        log "${RED}❌ POST /agent${NC}"
    fi
    
    # Test search
    if curl -f -s "$BACKEND_URL/api/taxcollect/agent/search?searchTerm=test" > /dev/null; then
        log "${GREEN}✅ GET /agent/search${NC}"
    else
        log "${RED}❌ GET /agent/search${NC}"
    fi
}

# Test Contribuable Controller
test_contribuable_controller() {
    log "${YELLOW}👥 Test Contribuable Controller...${NC}"
    
    # Test GET all
    if curl -f -s "$BACKEND_URL/api/taxcollect/contribuable/all" > /dev/null; then
        log "${GREEN}✅ GET /contribuable/all${NC}"
    else
        log "${RED}❌ GET /contribuable/all${NC}"
    fi
    
    # Test stats
    if curl -f -s "$BACKEND_URL/api/taxcollect/contribuable/stats" > /dev/null; then
        log "${GREEN}✅ GET /contribuable/stats${NC}"
    else
        log "${RED}❌ GET /contribuable/stats${NC}"
    fi
    
    # Test export
    if curl -f -s "$BACKEND_URL/api/taxcollect/contribuable/export?format=csv" > /dev/null; then
        log "${GREEN}✅ GET /contribuable/export${NC}"
    else
        log "${RED}❌ GET /contribuable/export${NC}"
    fi
}

# Test Taxe Controller
test_taxe_controller() {
    log "${YELLOW}💰 Test Taxe Controller...${NC}"
    
    # Test GET all
    if curl -f -s "$BACKEND_URL/api/taxcollect/taxe/all" > /dev/null; then
        log "${GREEN}✅ GET /taxe/all${NC}"
    else
        log "${RED}❌ GET /taxe/all${NC}"
    fi
    
    # Test categories
    if curl -f -s "$BACKEND_URL/api/taxcollect/taxe/categories" > /dev/null; then
        log "${GREEN}✅ GET /taxe/categories${NC}"
    else
        log "${RED}❌ GET /taxe/categories${NC}"
    fi
    
    # Test stats
    if curl -f -s "$BACKEND_URL/api/taxcollect/taxe/stats" > /dev/null; then
        log "${GREEN}✅ GET /taxe/stats${NC}"
    else
        log "${RED}❌ GET /taxe/stats${NC}"
    fi
}

# Test Transaction Controller
test_transaction_controller() {
    log "${YELLOW}🔄 Test Transaction Controller...${NC}"
    
    # Test GET all
    if curl -f -s "$BACKEND_URL/api/transactions" > /dev/null; then
        log "${GREEN}✅ GET /transactions${NC}"
    else
        log "${RED}❌ GET /transactions${NC}"
    fi
    
    # Test filter
    if curl -f -s "$BACKEND_URL/api/transactions/filter" > /dev/null; then
        log "${GREEN}✅ GET /transactions/filter${NC}"
    else
        log "${RED}❌ GET /transactions/filter${NC}"
    fi
    
    # Test stats
    if curl -f -s "$BACKEND_URL/api/transactions/stats" > /dev/null; then
        log "${GREEN}✅ GET /transactions/stats${NC}"
    else
        log "${RED}❌ GET /transactions/stats${NC}"
    fi
}

# Test Frontend
test_frontend() {
    log "${YELLOW}🎨 Test Frontend...${NC}"
    
    if curl -f -s "$FRONTEND_URL" > /dev/null; then
        log "${GREEN}✅ Frontend is accessible${NC}"
        
        # Test main pages
        PAGES=("/agents" "/contribuables" "/taxes" "/transactions" "/dashboard")
        
        for page in "${PAGES[@]}"; do
            if curl -f -s "$FRONTEND_URL$page" > /dev/null; then
                log "${GREEN}✅ Frontend$page${NC}"
            else
                log "${RED}❌ Frontend$page${NC}"
            fi
        done
    else
        log "${RED}❌ Frontend is not accessible${NC}"
    fi
}

# Generate Report
generate_report() {
    log "${BLUE}📊 Génération du rapport...${NC}"
    
    SUCCESS_COUNT=$(grep -c "✅" "$LOG_FILE")
    ERROR_COUNT=$(grep -c "❌" "$LOG_FILE")
    TOTAL_TESTS=$((SUCCESS_COUNT + ERROR_COUNT))
    
    log "${BLUE}=== RAPPORT DE TEST ===${NC}"
    log "Total Tests: $TOTAL_TESTS"
    log "Succès: $SUCCESS_COUNT"
    log "Erreurs: $ERROR_COUNT"
    
    if [ $ERROR_COUNT -eq 0 ]; then
        log "${GREEN}🎉 TOUS LES TESTS SONT PASSÉS!${NC}"
    else
        log "${RED}⚠️  $ERROR_COUNT test(s) ont échoué${NC}"
    fi
    
    log "Log complet: $LOG_FILE"
}

# Main execution
main() {
    case "${1:-all}" in
        "backend")
            test_backend_health && \
            test_agent_controller && \
            test_contribuable_controller && \
            test_taxe_controller && \
            test_transaction_controller
            ;;
        "frontend")
            test_frontend
            ;;
        "all")
            test_backend_health && \
            test_agent_controller && \
            test_contribuable_controller && \
            test_taxe_controller && \
            test_transaction_controller && \
            test_frontend
            ;;
        *)
            echo "Usage: $0 [backend|frontend|all]"
            exit 1
            ;;
    esac
    
    generate_report
}

# Run main function with all arguments
main "$@"
