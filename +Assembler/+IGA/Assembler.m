classdef Assembler < Assembler.AssemblerBase
    %ASSEMBLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = Assembler(dof_manager)
            this@Assembler.AssemblerBase(dof_manager);
        end
        
        function status = Assembly(this, type, var, basis_id, data)
            import Utility.BasicUtility.AssemblyType
            if(type == AssemblyType.Matrix)
                status = this.IGA_LHS_Assembly(var, basis_id, data);
            elseif(type == AssemblyType.Vector)
                status = this.IGA_RHS_Assembly(var, basis_id, data);
            elseif(type == AssemblyType.Constraint)
                status = this.IGA_Constraint_Assembly(var, basis_id, data);
            else
                disp('Error <IGA Assembler>! - Assembly!');
                disp('> your assembly type error, please check!');
                status = false;
            end
        end
    end
    
    methods(Access = private)
        function status = IGA_LHS_Assembly(this, var, basis_id, data)
            if(length(var) == 2 && length(basis_id) == 2)
                test = var{1};
                var = var{2};
                
                row_id = this.dof_manager_.getAssemblyId(test.variable_data_, basis_id{1});
                col_id = this.dof_manager_.getAssemblyId(var, basis_id{2});
                
                this.lhs_(row_id, col_id) = this.lhs_(row_id, col_id) + data;
                status = true;
            else
                disp('Error <IGA Assembler>! - IGA_LHS_Assembly!');
                disp('> LHS assembling error, please check!');
                status = false;
            end
        end
        
        function status = IGA_RHS_Assembly(this, var, basis_id, data)
            if(length(var) == 1 && length(basis_id) == 1)
                test = var{1};
                
                row_id = this.dof_manager_.getAssemblyId(test.variable_data_, basis_id{1});
                
                this.rhs_(row_id) = this.rhs_(row_id) + data;
                status = true;
            else
                disp('Error <IGA Assembler>! - IGA_RHS_Assembly!');
                disp('> RHS assembling error, please check!');
                status = false;
            end
        end
        
        function status = IGA_Constraint_Assembly(this, var, basis_id, data)       
            for i = 1:length(basis_id)
                if strcmp(data{i}.type, 'collocation')
                    dof_id = data{i}.dof;
                    
                    row_id = this.dof_manager_.getAssemblyId_by_DofId(var, basis_id(i), dof_id);
                    col_id = this.dof_manager_.getAssemblyId_by_DofId(var, data{i}.non_zero_id, dof_id);
                    
                    % erase lhs row value
                    this.lhs_(row_id, :) = 0;
                    this.lhs_(row_id, col_id) = data{i}.coefficient;
                    % put constraint value
                    this.rhs_(row_id) = data{i}.constraint_value;
                    status = true;
                elseif strcmp(data{i}.type, 'assign')
                    dof_id = data{i}.dof;
                    
                    row_id = this.dof_manager_.getAssemblyId_by_DofId(var, basis_id(i), dof_id);
                    
                    % erase lhs row value
                    this.lhs_(row_id, :) = 0;
                    this.lhs_(row_id, row_id) = 1;
                    % put constraint value
                    this.rhs_(row_id) = data{i}.constraint_value;
                    status = true;
                else
                    disp('Error <IGA Assembler>! - IGA_Constraint_Assembly!');
                    disp('> Constraint data format error, please check!');
                    status = false;
                end
            end

        end
    end
end

