#p nodesId #imprimir lista facil
#buscar nombre de nodos y la cantidad
nodesId = []
File.readlines('output.txt').each do |line|
    if nodesId.include?(line.split('"')[1]) == false && line.split('"')[1] != nil && line.split('"')[1] != "Id proceso"
        nodesId.push(line.split('"')[1])
    end
end

#ordenar nodos de menor a mayor
nodesId = nodesId.sort

#lista con capas. 
capasId = ["APP", "MPI-IO", "ADIO", "AD_PVFS", "SI", "JOB", "FLOW", "BMI", "ML", "JOB-S", "FLOW-S", "BMI-S", "TROVE"]

#Crear salida
output = File.open('porNodo.txt','w')
for i in nodesId
    for j in capasId
        File.readlines('output.txt').each do |line|
            if line.split('"')[1] == i && line.split('"')[3] == j
                output.write line
            end
        end
    end
end
output.close
puts "Salida creada en porNodo.txt"



